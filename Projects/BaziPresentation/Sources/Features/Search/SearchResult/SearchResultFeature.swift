// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain
import ComposableArchitecture

/// 검색 결과 화면. 분야 필터 + 정렬 + 결과 목록(커서 페이지네이션)으로 구성된다.
/// 필터·정렬·페이지네이션은 모두 서버가 처리한다.
@Reducer
public struct SearchResultFeature {

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable, Sendable {
        case deadline = "마감순"
        case latest = "등록순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }
        var serverValue: String { self == .deadline ? "DEADLINE" : "LATEST" }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let query: String
        public var selectedCategory: PolicyCategoryUI?
        public var sortOrder: SortOrder = .deadline
        public var results: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> = .idle
        public var pagination = PaginationState<String>()
        /// 홈·내정책이 반영하는 공유 찜 오버레이(id → liked).
        @Shared(.likeOverrides) public var likeOverrides: [Int: Bool] = [:]

        public init(query: String) {
            self.query = query
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapRetry
        case pullToRefresh
        case didSelectCategory(PolicyCategoryUI?)
        case didTapSortOrder
        case didReachListEnd
        case didToggleLike(id: Int)
        case didTapPolicy(id: Int)

        // MARK: Internal
        case pageResponse(Result<PolicyPageVO, UseCaseError>, isFirstPage: Bool)
        case likeFailed(id: Int, liked: Bool)

        // MARK: Delegate
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didSelectPolicy(id: Int)
        }
    }

    // MARK: - Dependencies

    @Dependency(\.policySearchClient) var policySearchClient
    @Dependency(\.policyLikeClient) var policyLikeClient

    // MARK: - Init

    public init() {}

    private static let pageSize = 20
    private enum CancelID: Hashable { case list, like(Int) }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear, .didTapRetry:
                return loadFirstPage(&state)

            case .pullToRefresh:
                return fetchPage(state, isFirstPage: true)

            case .didSelectCategory(let category):
                guard category != state.selectedCategory else { return .none }
                state.selectedCategory = category
                return reloadFirstPage(&state)

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                return reloadFirstPage(&state)

            case .didReachListEnd:
                guard state.pagination.canLoadNext, state.results.value != nil else { return .none }
                state.pagination.isLoadingNext = true
                return fetchPage(state, isFirstPage: false)

            case let .pageResponse(.success(page), isFirstPage):
                if isFirstPage {
                    state.results = .loaded(page.policies)
                } else {
                    var list = state.results.value ?? []
                    list.append(contentsOf: page.policies)
                    state.results = .loaded(list)
                }
                state.pagination.apply(page)
                return .none

            case let .pageResponse(.failure(error), isFirstPage):
                state.pagination.isLoadingNext = false
                if isFirstPage, state.results.value == nil {
                    state.results = .failed(error.loadFailureMessage)
                }
                return .none

            case .didToggleLike(let id):
                guard let localLiked = state.results.value?[id: id]?.isLiked else { return .none }
                // 표시값(overlay ?? 로컬)을 기준으로 뒤집어야 첫 탭이 헛돌지 않는다.
                let current = state.likeOverrides[id] ?? localLiked
                let newValue = !current
                setLiked(&state, id: id, liked: newValue)
                return likeEffect(id: id, liked: newValue)

            case let .likeFailed(id, liked):
                // 그 사이 다른 화면이 overlay를 바꿨으면 덮지 않는다(내 낙관값이 남아있을 때만 롤백).
                setLiked(&state, id: id, liked: !liked, writeOverlay: state.likeOverrides[id] == liked)
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private func loadFirstPage(_ state: inout State) -> Effect<Action> {
        if state.results.isLoading || state.results.value != nil { return .none }
        return reloadFirstPage(&state)
    }

    private func reloadFirstPage(_ state: inout State) -> Effect<Action> {
        state.pagination.reset()
        state.results = .loading
        return fetchPage(state, isFirstPage: true)
    }

    private func fetchPage(_ state: State, isFirstPage: Bool) -> Effect<Action> {
        let cursor = isFirstPage ? nil : state.pagination.nextCursor
        let query = state.query
        let category = state.selectedCategory
        let sort = state.sortOrder.serverValue
        return .run { [policySearchClient] send in
            do {
                let page = try await policySearchClient.search(query, category, sort, cursor, Self.pageSize)
                await send(.pageResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.pageResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.list, cancelInFlight: true)
    }

    private func setLiked(_ state: inout State, id: Int, liked: Bool, writeOverlay: Bool = true) {
        if writeOverlay { state.$likeOverrides.withLock { $0[id] = liked } }
        guard var list = state.results.value else { return }
        list[id: id]?.isLiked = liked
        state.results = .loaded(list)
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
}
