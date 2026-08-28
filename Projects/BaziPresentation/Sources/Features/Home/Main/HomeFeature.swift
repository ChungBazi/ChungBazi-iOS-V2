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

    /// 홈 화면에서 찜 토글이 어느 섹션의 배열을 바꿔야 하는지 구분한다.
    public enum PolicySection: Equatable, Sendable {
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
        /// 인사말·맞춤정책 타이틀용 사용자 이름. 세션(로컬 저장)에서 읽는다.
        public var userName = ""

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case task
        case didTapRetry
        case pullToRefresh
        case didTapBell
        case didTapCategory(PolicyCategoryUI)
        case didTapPersonalizedMore
        case didTapPersonalizedEmptyCTA
        case didTapPopularMore
        case didTapDeadlineMore
        case didTapNewMore
        case didTapPolicy(section: PolicySection, id: Int)
        case didToggleLike(section: PolicySection, id: Int)

        // MARK: Internal
        case feedResponse(Result<HomeFeedVO, UseCaseError>)
        case likeFailed(id: Int, liked: Bool)

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    @Dependency(\.homeClient) var homeClient
    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.policyLikeClient) var policyLikeClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                state.userName = sessionClient.userName() ?? ""
                return loadFeed(&state)

            case .didTapRetry:
                return loadFeed(&state)

            case .pullToRefresh:
                // 당김 새로고침: .loading으로 바꾸지 않고 캐시를 우회해 다시 가져온다.
                return .run { [homeClient] send in
                    do {
                        let feed = try await homeClient.fetchHomeFeed(true)
                        await send(.feedResponse(.success(feed)))
                    } catch {
                        await send(.feedResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case let .feedResponse(.success(feed)):
                state.feed = .loaded(feed)
                // 홈 피드 조회 시 서버 닉네임이 세션에 저장되므로, 재로그인 등으로 비어 있던 인사말 이름을 갱신한다.
                if let name = sessionClient.userName() {
                    state.userName = name
                }
                return .none

            case let .feedResponse(.failure(error)):
                // 새로고침 실패 시 기존 데이터는 유지, 데이터가 없을 때만 실패 화면.
                if state.feed.value == nil {
                    state.feed = .failed(error.loadFailureMessage)
                }
                return .none

            case .didTapBell:
                // TODO: 알림 Feature가 준비되면 연결한다.
                return .none

            case .didTapCategory(let category):
                state.path.append(.categoryPolicyList(CategoryPolicyListFeature.State(selectedCategory: category)))
                return .none

            case .didTapPersonalizedMore:
                let ids = state.feed.value?.personalized.map(\.id) ?? []
                state.path.append(.customPolicyList(CustomPolicyListFeature.State(policyIds: ids)))
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

            case .didToggleLike(let section, let id):
                guard let current = currentLike(section: section, id: id, state: state) else { return .none }
                let newValue = !current
                setLiked(id: id, liked: newValue, state: &state)
                return likeEffect(id: id, liked: newValue)

            case let .likeFailed(id, liked):
                setLiked(id: id, liked: !liked, state: &state)
                return .none

            case .path(.element(_, .categoryPolicyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .rankedPolicyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .customPolicyList(.delegate(.didSelectPolicy)))):
                state.path.append(.detail(PlaceholderDetailFeature.State(id: UUID())))
                return .none

            case let .path(.element(_, .categoryPolicyList(.delegate(.didTapPersonalizedMore(category, policyIds))))):
                state.path.append(.customPolicyList(CustomPolicyListFeature.State(category: category, policyIds: policyIds)))
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
                let feed = try await homeClient.fetchHomeFeed(false)
                await send(.feedResponse(.success(feed)))
            } catch {
                await send(.feedResponse(.failure(UseCaseError.map(error))))
            }
        }
    }

    private enum CancelID: Hashable { case like(Int) }

    private func currentLike(section: PolicySection, id: Int, state: State) -> Bool? {
        guard let feed = state.feed.value else { return nil }
        switch section {
        case .personalized: return feed.personalized[id: id]?.isLiked
        case .recentViewed: return feed.recentViewed[id: id]?.isLiked
        case .popular: return feed.popular[id: id]?.isLiked
        case .deadline: return feed.deadline[id: id]?.isLiked
        case .newest: return feed.newest[id: id]?.isLiked
        }
    }

    /// 찜 상태를 모든 섹션에 반영한다(같은 정책이 여러 섹션에 겹칠 수 있음).
    private func setLiked(id: Int, liked: Bool, state: inout State) {
        guard var feed = state.feed.value else { return }
        feed.setLiked(id: id, liked: liked)
        state.feed = .loaded(feed)
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
}

extension HomeFeature.Path.State: Equatable {}
