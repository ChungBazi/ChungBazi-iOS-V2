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
        public var selectedCategory: PolicyCategory
        public var userName = ""
        public var sortOrder: SortOrder = .deadline

        public var teaser: IdentifiedArrayOf<PolicySummary> = []
        public var list: LoadingState<IdentifiedArrayOf<PolicySummary>> = .idle

        // 페이지네이션
        public var nextCursor: String?
        public var hasNext = false
        public var isLoadingNext = false
        public var totalCount = 0

        public init(selectedCategory: PolicyCategory) {
            self.selectedCategory = selectedCategory
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case task
        case didTapRetry
        case pullToRefresh
        case didSelectCategory(PolicyCategory)
        case didTapSortOrder
        case didTapPersonalizedMore
        case didReachListEnd
        case didToggleTeaserBookmark(id: Int)
        case didToggleBookmark(id: Int)
        case didTapPolicy(id: Int)

        // MARK: Internal
        case pageResponse(Result<PolicyPageVO, UseCaseError>, isFirstPage: Bool)
        case teaserResponse(Result<[PolicySummary], UseCaseError>)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
        case didTapPersonalizedMore(PolicyCategory)
    }

    // MARK: - Dependencies

    @Dependency(\.categoryPolicyClient) var categoryPolicyClient
    @Dependency(\.sessionClient) var sessionClient

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
                guard state.hasNext, !state.isLoadingNext, state.list.value != nil else { return .none }
                state.isLoadingNext = true
                return fetchPage(state: state, isFirstPage: false)

            case .didTapPersonalizedMore:
                return .send(.delegate(.didTapPersonalizedMore(state.selectedCategory)))

            case let .pageResponse(.success(page), isFirstPage):
                handlePage(page, isFirstPage: isFirstPage, state: &state)
                return .none

            case let .pageResponse(.failure(error), isFirstPage):
                if isFirstPage {
                    // 새로고침 실패 시 기존 데이터는 유지, 데이터가 없을 때만 실패 화면.
                    if state.list.value == nil {
                        state.list = .failed(message(for: error))
                    }
                } else {
                    state.isLoadingNext = false
                }
                return .none

            case .teaserResponse(.success(let policies)):
                state.teaser = IdentifiedArray(uniqueElements: policies)
                return .none

            case .teaserResponse(.failure):
                state.teaser = []
                return .none

            case .didToggleTeaserBookmark(let id):
                state.teaser[id: id]?.isBookmarked.toggle()
                return .none

            case .didToggleBookmark(let id):
                guard var policies = state.list.value else { return .none }
                policies[id: id]?.isBookmarked.toggle()
                state.list = .loaded(policies)
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private enum CancelID { case list }

    private static let pageSize = 20

    /// 1페이지부터 다시 조회한다. 진행 중인 요청은 취소한다.
    private func reloadFirstPage(_ state: inout State) -> Effect<Action> {
        state.list = .loading
        state.nextCursor = nil
        state.hasNext = false
        state.isLoadingNext = false
        return fetchPage(state: state, isFirstPage: true)
    }

    private func fetchPage(state: State, isFirstPage: Bool) -> Effect<Action> {
        let category = state.selectedCategory
        let sort = state.sortOrder.serverValue
        let cursor = isFirstPage ? nil : state.nextCursor
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
        state.nextCursor = page.nextCursor
        state.hasNext = page.hasNext
        state.totalCount = page.totalCount
        state.isLoadingNext = false
        if isFirstPage {
            state.list = .loaded(page.policies)
        } else {
            var current = state.list.value ?? []
            current.append(contentsOf: page.policies)
            state.list = .loaded(current)
        }
    }

    private func message(for error: UseCaseError) -> String {
        switch error {
        case .network: return "네트워크 연결을 확인해 주세요."
        case .cancelled, .unknown: return "정책을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
}
