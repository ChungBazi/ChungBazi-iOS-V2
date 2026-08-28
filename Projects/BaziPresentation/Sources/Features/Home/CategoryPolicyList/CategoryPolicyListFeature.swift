// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain
import ComposableArchitecture

/// 홈 "분야별 정책" 더보기 화면 (13-1). 분야 탭 전환 + 맞춤 정책 배너 + 정렬 가능한 목록(커서 페이지네이션)으로 구성된다.
@Reducer
public struct CategoryPolicyListFeature {

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable {
        case deadline = "마감순"
        case latest = "최신순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }

        /// 서버 정렬 파라미터 값.
        var serverValue: String { self == .deadline ? "DEADLINE" : "LATEST" }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedCategory: PolicyCategoryUI
        public var userName = ""
        public var sortOrder: SortOrder = .deadline

        public var teaser: IdentifiedArrayOf<PolicySummaryVO> = []
        public var list: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> = .idle

        // 페이지네이션
        public var pagination = PaginationState()

        public init(selectedCategory: PolicyCategoryUI) {
            self.selectedCategory = selectedCategory
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case task
        case didTapRetry
        case pullToRefresh
        case didSelectCategory(PolicyCategoryUI)
        case didTapSortOrder
        case didTapPersonalizedMore
        case didReachListEnd
        case didToggleTeaserLike(id: Int)
        case didToggleLike(id: Int)
        case didTapPolicy(id: Int)

        // MARK: Internal
        case pageResponse(Result<PolicyPageVO, UseCaseError>, isFirstPage: Bool)
        case teaserResponse(Result<[PolicySummaryVO], UseCaseError>)
        case likeFailed(id: Int, liked: Bool)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
        case didTapPersonalizedMore(category: PolicyCategoryUI, policyIds: [Int])
    }

    // MARK: - Dependencies

    @Dependency(\.categoryPolicyClient) var categoryPolicyClient
    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.policyLikeClient) var policyLikeClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                guard state.list.value == nil, !state.list.isLoading else { return .none }
                state.userName = sessionClient.userName() ?? ""
                let first = reloadFirstPage(&state)
                let teaser = loadTeaser(state)
                return .merge(first, teaser)

            case .didTapRetry:
                return reloadFirstPage(&state)

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 1페이지 + 티저만 다시 가져온다.
                return .merge(fetchPage(state: state, isFirstPage: true), loadTeaser(state))

            case .didSelectCategory(let category):
                guard category != state.selectedCategory else { return .none }
                state.selectedCategory = category
                let first = reloadFirstPage(&state)
                let teaser = loadTeaser(state)
                return .merge(first, teaser)

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                return reloadFirstPage(&state)

            case .didReachListEnd:
                guard state.pagination.canLoadNext, state.list.value != nil else { return .none }
                state.pagination.isLoadingNext = true
                return fetchPage(state: state, isFirstPage: false)

            case .didTapPersonalizedMore:
                return .send(.delegate(.didTapPersonalizedMore(category: state.selectedCategory, policyIds: state.teaser.map(\.id))))

            case let .pageResponse(.success(page), isFirstPage):
                handlePage(page, isFirstPage: isFirstPage, state: &state)
                return .none

            case let .pageResponse(.failure(error), isFirstPage):
                if isFirstPage {
                    // 새로고침 실패 시 기존 데이터는 유지, 데이터가 없을 때만 실패 화면.
                    if state.list.value == nil {
                        state.list = .failed(error.loadFailureMessage)
                    }
                } else {
                    state.pagination.isLoadingNext = false
                }
                return .none

            case .teaserResponse(.success(let policies)):
                state.teaser = IdentifiedArray(uniqueElements: policies)
                return .none

            case .teaserResponse(.failure):
                state.teaser = []
                return .none

            case .didToggleTeaserLike(let id), .didToggleLike(let id):
                let current = state.teaser[id: id]?.isLiked ?? state.list.value?[id: id]?.isLiked
                guard let current else { return .none }
                let newValue = !current
                setLiked(&state, id: id, liked: newValue)
                return likeEffect(id: id, liked: newValue)

            case let .likeFailed(id, liked):
                setLiked(&state, id: id, liked: !liked)
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private enum CancelID: Hashable { case list, like(Int) }

    private static let pageSize = 20

    /// 찜 상태를 teaser·list 양쪽에 반영한다.
    private func setLiked(_ state: inout State, id: Int, liked: Bool) {
        if state.teaser[id: id] != nil {
            state.teaser[id: id]?.isLiked = liked
        }
        if var list = state.list.value, list[id: id] != nil {
            list[id: id]?.isLiked = liked
            state.list = .loaded(list)
        }
    }

    /// 찜 토글: 서버 반영. 실패 시 likeFailed로 롤백. 연타는 정책별로 취소.
    private func likeEffect(id: Int, liked: Bool) -> Effect<Action> {
        .run { [policyLikeClient] send in
            do {
                try await policyLikeClient.setLike(id, liked)
            } catch {
                await send(.likeFailed(id: id, liked: liked))
            }
        }
        .cancellable(id: CancelID.like(id), cancelInFlight: true)
    }

    /// 1페이지부터 다시 조회한다. 진행 중인 요청은 취소한다.
    private func reloadFirstPage(_ state: inout State) -> Effect<Action> {
        state.list = .loading
        state.pagination.reset()
        return fetchPage(state: state, isFirstPage: true)
    }

    private func fetchPage(state: State, isFirstPage: Bool) -> Effect<Action> {
        let category = state.selectedCategory
        let sort = state.sortOrder.serverValue
        let cursor = isFirstPage ? nil : state.pagination.nextCursor
        return .run { [categoryPolicyClient] send in
            do {
                let page = try await categoryPolicyClient.fetchPolicies(category, sort, cursor, Self.pageSize)
                await send(.pageResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.pageResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.list, cancelInFlight: true)
    }

    private func loadTeaser(_ state: State) -> Effect<Action> {
        let category = state.selectedCategory
        return .run { [categoryPolicyClient] send in
            do {
                let policies = try await categoryPolicyClient.fetchPersonalized(category)
                await send(.teaserResponse(.success(policies)))
            } catch {
                await send(.teaserResponse(.failure(UseCaseError.map(error))))
            }
        }
    }

    private func handlePage(_ page: PolicyPageVO, isFirstPage: Bool, state: inout State) {
        state.pagination.apply(page)
        if isFirstPage {
            state.list = .loaded(page.policies)
        } else {
            var current = state.list.value ?? []
            current.append(contentsOf: page.policies)
            state.list = .loaded(current)
        }
    }
}
