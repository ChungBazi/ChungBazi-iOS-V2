// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain
import ComposableArchitecture

/// 홈 "인기/마감임박/새로 뜬 정책"의 더보기 화면. 세 화면이 레이아웃을 공유하므로
/// `Kind`로 문구·조회 기준을 구분한다
@Reducer
public struct RankedPolicyListFeature {

    // MARK: - Kind

    public enum Kind: Equatable {
        case popular
        case deadline
        case latest

        public var navigationTitle: String {
            switch self {
            case .popular: return "인기 정책"
            case .deadline: return "마감 임박 정책"
            case .latest: return "새로 뜬 정책"
            }
        }

        public var bannerTitle: String {
            switch self {
            case .popular: return "가장 인기 있는 정책을 모아봤어요!"
            case .deadline: return "곧 마감되는 정책을 놓치지 마세요!"
            case .latest: return "따끈한 정책을 먼저 확인해봐요!"
            }
        }

        /// 순위 배지는 인기 정책에서만 보여준다.
        public var showsRankBadge: Bool { self == .popular }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let kind: Kind
        public var selectedCategory: PolicyCategoryUI
        public var teaser: IdentifiedArrayOf<PolicySummaryVO> = []
        public var list: LoadingState<IdentifiedArrayOf<PolicySummaryVO>> = .idle

        // 페이지네이션
        public var pagination = PaginationState()

        public init(kind: Kind, selectedCategory: PolicyCategoryUI = .job) {
            self.kind = kind
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
    }

    // MARK: - Dependencies

    @Dependency(\.rankedPolicyClient) var rankedPolicyClient
    @Dependency(\.policyLikeClient) var policyLikeClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                guard state.list.value == nil, !state.list.isLoading else { return .none }
                return .merge(reloadFirstPage(&state), loadTeaser(state))

            case .didTapRetry:
                return reloadFirstPage(&state)

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 1페이지 + teaser만 다시 가져온다.
                return .merge(fetchPage(state: state, isFirstPage: true), loadTeaser(state))

            case .didSelectCategory(let category):
                guard category != state.selectedCategory else { return .none }
                state.selectedCategory = category
                // teaser는 분야 무관(전체 상위) 고정이므로 목록만 재조회한다.
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
    private static let teaserSize = 10

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

    /// kind에 해당하는 조회 클로저.
    private func fetchClosure(for kind: Kind) -> @Sendable (PolicyCategoryUI?, String?, Int) async throws -> PolicyPageVO {
        switch kind {
        case .popular: return rankedPolicyClient.fetchPopular
        case .deadline: return rankedPolicyClient.fetchDeadline
        case .latest: return rankedPolicyClient.fetchLatest
        }
    }

    private func reloadFirstPage(_ state: inout State) -> Effect<Action> {
        state.list = .loading
        state.pagination.reset()
        return fetchPage(state: state, isFirstPage: true)
    }

    private func fetchPage(state: State, isFirstPage: Bool) -> Effect<Action> {
        let fetch = fetchClosure(for: state.kind)
        let category = state.selectedCategory
        let cursor = isFirstPage ? nil : state.pagination.nextCursor
        return .run { send in
            do {
                let page = try await fetch(category, cursor, Self.pageSize)
                await send(.pageResponse(.success(page), isFirstPage: isFirstPage))
            } catch {
                await send(.pageResponse(.failure(UseCaseError.map(error)), isFirstPage: isFirstPage))
            }
        }
        .cancellable(id: CancelID.list, cancelInFlight: true)
    }

    private func loadTeaser(_ state: State) -> Effect<Action> {
        let fetch = fetchClosure(for: state.kind)
        return .run { send in
            do {
                let page = try await fetch(nil, nil, Self.teaserSize)
                await send(.teaserResponse(.success(Array(page.policies))))
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
