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
        case likeFailed(policy: PolicySummaryVO, index: Int)

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
                // 내 정책(찜한 목록) — 좋아요 해제 시 목록에서 즉시 제거(낙관적). 실패 시 원위치 복구.
                guard var list = state.list.value, let index = list.index(id: id) else { return .none }
                let removed = list.remove(at: index)
                state.list = .loaded(list)
                state.pagination.totalCount = max(0, state.pagination.totalCount - 1)
                return .run { [policyLikeClient] send in
                    do {
                        try await policyLikeClient.setLike(id, false)
                    } catch {
                        await send(.likeFailed(policy: removed, index: index))
                    }
                }
                .cancellable(id: CancelID.like(id), cancelInFlight: true)

            case let .likeFailed(policy, index):
                guard var list = state.list.value else { return .none }
                list.insert(policy, at: min(index, list.count))
                state.list = .loaded(list)
                state.pagination.totalCount += 1
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
