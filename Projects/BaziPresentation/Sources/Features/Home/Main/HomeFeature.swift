// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import ComposableArchitecture

@Reducer
public struct HomeFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case categoryPolicyList(CategoryPolicyListFeature)
        case rankedPolicyList(RankedPolicyListFeature)
        case customPolicyList(CustomPolicyListFeature)
        case detail(PlaceholderDetailFeature)
    }

    // MARK: - PolicySection

    /// 홈 화면에서 북마크 토글이 어느 섹션의 배열을 바꿔야 하는지 구분한다.
    public enum PolicySection: Equatable {
        case personalized
        case recentViewed
        case popular
        case deadline
        case newest
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()
        public var feed: LoadingState<HomeFeedVO> = .idle

        /// 인사말·맞춤정책 타이틀에 쓰는 사용자 이름. 로드된 피드에서 파생한다.
        public var userName: String { feed.value?.userName ?? "" }

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case task
        case didTapRetry
        case didTapBell
        case didTapCategory(PolicyCategory)
        case didTapPersonalizedMore
        case didTapPersonalizedEmptyCTA
        case didTapPopularMore
        case didTapDeadlineMore
        case didTapNewMore
        case didTapPolicy(section: PolicySection, id: Int)
        case didToggleBookmark(section: PolicySection, id: Int)

        // MARK: Internal
        case feedResponse(Result<HomeFeedVO, UseCaseError>)

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    @Dependency(\.homeClient) var homeClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task, .didTapRetry:
                return loadFeed(&state)

            case let .feedResponse(.success(feed)):
                state.feed = .loaded(feed)
                return .none

            case let .feedResponse(.failure(error)):
                state.feed = .failed(message(for: error))
                return .none

            case .didTapBell:
                // TODO: 알림 Feature가 준비되면 연결한다.
                return .none

            case .didTapCategory(let category):
                state.path.append(.categoryPolicyList(CategoryPolicyListFeature.State(selectedCategory: category)))
                return .none

            case .didTapPersonalizedMore:
                state.path.append(.customPolicyList(CustomPolicyListFeature.State(userName: state.userName)))
                return .none

            case .didTapPersonalizedEmptyCTA:
                // TODO: SharedRoute.policyRecommendationEdit(맞춤 조건 다시 설정) Feature가 준비되면 연결한다.
                return .none

            case .didTapPopularMore:
                state.path.append(.rankedPolicyList(RankedPolicyListFeature.State(kind: .popular)))
                return .none

            case .didTapDeadlineMore:
                state.path.append(.rankedPolicyList(RankedPolicyListFeature.State(kind: .deadline)))
                return .none

            case .didTapNewMore:
                state.path.append(.rankedPolicyList(RankedPolicyListFeature.State(kind: .latest)))
                return .none

            case .didTapPolicy:
                state.path.append(.detail(PlaceholderDetailFeature.State(id: UUID())))
                return .none

            case .didToggleBookmark(let section, let id):
                toggleBookmark(section: section, id: id, state: &state)
                return .none

            case .path(.element(_, .categoryPolicyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .rankedPolicyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .customPolicyList(.delegate(.didSelectPolicy)))):
                state.path.append(.detail(PlaceholderDetailFeature.State(id: UUID())))
                return .none

            case let .path(.element(_, .categoryPolicyList(.delegate(.didTapPersonalizedMore(category))))):
                state.path.append(.customPolicyList(CustomPolicyListFeature.State(userName: state.userName, category: category)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    /// 홈 피드를 조회한다. 이미 로딩 중이거나 로드 완료면 재요청하지 않는다.
    private func loadFeed(_ state: inout State) -> Effect<Action> {
        if state.feed.isLoading || state.feed.value != nil { return .none }
        state.feed = .loading
        return .run { [homeClient] send in
            do {
                let feed = try await homeClient.fetchHomeFeed()
                await send(.feedResponse(.success(feed)))
            } catch {
                await send(.feedResponse(.failure(UseCaseError.map(error))))
            }
        }
    }

    private func toggleBookmark(section: PolicySection, id: Int, state: inout State) {
        guard var feed = state.feed.value else { return }
        switch section {
        case .personalized: feed.personalized[id: id]?.isBookmarked.toggle()
        case .recentViewed: feed.recentViewed[id: id]?.isBookmarked.toggle()
        case .popular: feed.popular[id: id]?.isBookmarked.toggle()
        case .deadline: feed.deadline[id: id]?.isBookmarked.toggle()
        case .newest: feed.newest[id: id]?.isBookmarked.toggle()
        }
        state.feed = .loaded(feed)
    }

    private func message(for error: UseCaseError) -> String {
        switch error {
        case .network: return "네트워크 연결을 확인해 주세요."
        case .cancelled, .unknown: return "정책을 불러오지 못했어요. 잠시 후 다시 시도해 주세요."
        }
    }
}

extension HomeFeature.Path.State: Equatable {}
