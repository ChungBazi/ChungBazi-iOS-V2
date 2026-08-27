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
        public var selectedCategory: PolicyCategory
        public var teaser: IdentifiedArrayOf<PolicySummary> = []
        public var list: LoadingState<IdentifiedArrayOf<PolicySummary>> = .idle

        // 페이지네이션
        public var nextCursor: String?
        public var hasNext = false
        public var isLoadingNext = false
        public var totalCount = 0

        public init(kind: Kind, selectedCategory: PolicyCategory = .job) {
            self.kind = kind
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
    }

    // MARK: - Dependencies

    @Dependency(\.rankedPolicyClient) var rankedPolicyClient

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
                guard state.hasNext, !state.isLoadingNext, state.list.value != nil else { return .none }
                state.isLoadingNext = true
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
    private static let teaserSize = 10

    /// kind에 해당하는 조회 클로저.
    private func fetchClosure(for kind: Kind) -> @Sendable (PolicyCategory?, String?, Int) async throws -> PolicyPageVO {
        switch kind {
        case .popular: return rankedPolicyClient.fetchPopular
        case .deadline: return rankedPolicyClient.fetchDeadline
        case .latest: return rankedPolicyClient.fetchLatest
        }
    }

    private func reloadFirstPage(_ state: inout State) -> Effect<Action> {
        state.list = .loading
        state.nextCursor = nil
        state.hasNext = false
        state.isLoadingNext = false
        return fetchPage(state: state, isFirstPage: true)
    }

    private func fetchPage(state: State, isFirstPage: Bool) -> Effect<Action> {
        let fetch = fetchClosure(for: state.kind)
        let category = state.selectedCategory
        let cursor = isFirstPage ? nil : state.nextCursor
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
}
