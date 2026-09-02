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
        /// 목록 새로고침 세대. 찜 해제 롤백이 지난 조회 결과(정렬·카테고리·새로고침으로 교체됨)에 잘못 적용되지 않도록 검증한다.
        public var reloadGeneration = 0
        /// 다른 화면에서 찜 해제된 정책도 목록에서 제외하기 위한 공유 오버레이(id → liked).
        @Shared(.likeOverrides) public var likeOverrides: [Int: Bool] = [:]

        /// 마지막 조회 시점의 오버레이 스냅샷. 다른 화면에서 찜이 바뀌면(신규 찜 주입) 재조회 트리거로 쓴다.
        /// 이 화면의 직접 토글은 목록을 즉시 갱신하므로 스냅샷도 함께 동기화해 불필요한 재조회를 막는다.
        public var lastSyncedLikeOverrides: [Int: Bool] = [:]

        /// 서버 총개수에서 다른 화면발 찜 해제(overlay == false)로 숨겨진 로드분을 뺀 값.
        /// 이 화면의 직접 해제는 list에서 항목을 이미 제거하므로 중복 차감되지 않는다.
        public var visibleTotalCount: Int {
            let hidden = (list.value ?? []).filter { likeOverrides[$0.id] == false }.count
            return max(0, pagination.totalCount - hidden)
        }

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
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
        case likeFailed(policy: PolicySummaryVO, index: Int, generation: Int)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
        /// 찜한 정책이 없을 때 "둘러보러 가기" → 상위(MyPolicy)가 선택한 분야의 분야별 정책으로 이동시킨다.
        case browsePolicies(category: PolicyCategoryUI?)
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
            case .onAppear:
                if state.list.value == nil {
                    guard !state.list.isLoading else { return .none }
                    state.lastSyncedLikeOverrides = state.likeOverrides
                    return reloadFirstPage(&state)
                }
                // 재진입: 신규 찜(추가)이 생겼을 때만 1페이지 재조회한다.
                // 해제는 overlay 필터가 반응형으로 처리하므로 재조회가 필요 없다.
                let overrides = state.likeOverrides
                let synced = state.lastSyncedLikeOverrides
                let hasNewLike = overrides.contains { $0.value && synced[$0.key] != true }
                state.lastSyncedLikeOverrides = overrides
                guard hasNewLike else { return .none }
                state.reloadGeneration += 1
                return fetchPage(state: state, isFirstPage: true)

            case .didTapRetry:
                return reloadFirstPage(&state)

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 1페이지만 다시 가져온다. (진행 중 낙관적 롤백은 세대 교체로 무효화)
                state.reloadGeneration += 1
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
                state.$likeOverrides.withLock { $0[id] = false }
                state.lastSyncedLikeOverrides = state.likeOverrides  // 자체 변경은 스냅샷 동기화(onChange 재조회 방지)
                let generation = state.reloadGeneration
                return .run { [policyLikeClient] send in
                    do {
                        try await policyLikeClient.setLike(id, false)
                    } catch {
                        await send(.likeFailed(policy: removed, index: index, generation: generation))
                    }
                }
                .cancellable(id: CancelID.like(id), cancelInFlight: true)

            case let .likeFailed(policy, index, generation):
                // 해제 실패 → 오버레이 복구(찜 유지). 단 그 사이 다른 화면이 overlay를 바꿨으면 덮지 않는다(낙관값 false가 남아있을 때만).
                if state.likeOverrides[policy.id] == false {
                    state.$likeOverrides.withLock { $0[policy.id] = true }
                }
                state.lastSyncedLikeOverrides = state.likeOverrides
                // 목록 재삽입은 조회 세대가 같을 때만(다른 조회 결과 오염 방지).
                guard generation == state.reloadGeneration, var list = state.list.value else { return .none }
                list.insert(policy, at: min(index, list.count))
                state.list = .loaded(list)
                state.pagination.totalCount += 1
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .didTapBrowsePolicies:
                return .send(.delegate(.browsePolicies(category: state.selectedCategory)))

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
        state.reloadGeneration += 1
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
