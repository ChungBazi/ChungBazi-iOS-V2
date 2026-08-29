// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain
import ComposableArchitecture

/// 내 정책 전체보기 화면 (20). 분야 필터 + 정렬(서버) + 찜한 정책 목록(커서 무한스크롤)으로 구성된다.
@Reducer
public struct MyPolicyListFeature {

    // MARK: - SortOrder

    public enum SortOrder: Equatable {
        case deadline
        case latest

        var title: String {
            switch self {
            case .deadline: return "마감순"
            case .latest: return "최신순"
            }
        }

        /// 서버 정렬 파라미터 값.
        var serverValue: String {
            switch self {
            case .deadline: return "DEADLINE"
            case .latest: return "LATEST"
            }
        }

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        /// nil이면 전체(분야 필터 해제).
        public var selectedCategory: PolicyCategoryUI?
        public var sortOrder: SortOrder = .deadline
        public var list: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> = .idle
        public var pagination = PaginationState<String>()

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case task
        case didTapRetry
        case pullToRefresh
        case didSelectCategory(PolicyCategoryUI?)
        case didTapSortOrder
        case didReachListEnd
        case didToggleLike(id: Int)
        case didTapPolicy(id: Int)
        case didTapBrowsePolicies

        // MARK: Internal
        case pageResponse(Result<PolicyPageVO, UseCaseError>, isFirstPage: Bool)
        case likeFailed(id: Int, liked: Bool)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
    }

    // MARK: - Dependencies

    @Dependency(\.myPolicyListClient) var myPolicyListClient
    @Dependency(\.policyLikeClient) var policyLikeClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                guard state.list.value == nil, !state.list.isLoading else { return .none }
                return reloadFirstPage(&state)

            case .didTapRetry:
                return reloadFirstPage(&state)

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 1페이지만 다시 가져온다.
                return fetchPage(state: state, isFirstPage: true)

            case .didSelectCategory(let category):
                guard category != state.selectedCategory else { return .none }
                state.selectedCategory = category
                return reloadFirstPage(&state)

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                return reloadFirstPage(&state)

            case .didReachListEnd:
                guard state.pagination.canLoadNext, state.list.value != nil else { return .none }
                state.pagination.isLoadingNext = true
                return fetchPage(state: state, isFirstPage: false)

            case let .pageResponse(.success(page), isFirstPage):
                handlePage(page, isFirstPage: isFirstPage, state: &state)
                return .none

            case let .pageResponse(.failure(error), isFirstPage):
                if isFirstPage {
                    if state.list.value == nil {
                        state.list = .failed(error.loadFailureMessage)
                    }
                } else {
                    state.pagination.isLoadingNext = false
                }
                return .none

            case .didToggleLike(let id):
                guard let current = state.list.value?[id: id]?.isLiked else { return .none }
                let newValue = !current
                setLiked(&state, id: id, liked: newValue)
                return likeEffect(id: id, liked: newValue)

            case let .likeFailed(id, liked):
                setLiked(&state, id: id, liked: !liked)
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .didTapBrowsePolicies:
                // TODO: 정책 둘러보기(홈/검색 등)로 이동 연결.
                return .none

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private enum CancelID: Hashable { case list, like(Int) }

    private static let pageSize = 20

    private func setLiked(_ state: inout State, id: Int, liked: Bool) {
        guard var list = state.list.value, list[id: id] != nil else { return }
        list[id: id]?.isLiked = liked
        state.list = .loaded(list)
    }

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
        return .run { [myPolicyListClient] send in
            do {
                let page = try await myPolicyListClient.fetchMyPolicies(category, sort, cursor, Self.pageSize)
                await send(.pageResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.pageResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.list, cancelInFlight: true)
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
