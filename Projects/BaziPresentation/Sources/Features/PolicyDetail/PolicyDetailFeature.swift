// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain
import ComposableArchitecture

/// 정책 상세 화면. 모든 정책 카드에서 진입하는 공용 화면이다. 상세와 추천 정책을 함께 조회한다.
@Reducer
public struct PolicyDetailFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable, Identifiable {
        public let policyId: Int
        public var detail: LoadingState<PolicyDetailVO> = .idle
        public var displayName: String = ""
        /// 홈·내정책이 반영하는 공유 찜 오버레이(id → liked).
        @Shared(.likeOverrides) public var likeOverrides: [Int: Bool] = [:]

        public var id: Int { policyId }

        public init(policyId: Int) {
            self.policyId = policyId
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapRetry
        case didTapLike
        case didTapApply
        case didTapShare
        case didToggleRecommendationLike(section: RecommendationSection, id: Int)
        case didTapPolicy(id: Int)

        // MARK: Internal
        case detailResponse(Result<PolicyDetailVO, UseCaseError>)
        case likeFailed(liked: Bool)
        case recommendationLikeFailed(section: RecommendationSection, id: Int, liked: Bool)

        // MARK: Delegate
        case delegate(Delegate)

        public enum Delegate: Equatable {
            case didSelectPolicy(id: Int)
        }
    }

    // MARK: - RecommendationSection

    public enum RecommendationSection: Equatable, Sendable {
        case personalized
        case popular
    }

    // MARK: - Dependencies

    @Dependency(\.policyDetailClient) var policyDetailClient
    @Dependency(\.policyLikeClient) var policyLikeClient
    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.openURL) var openURL
    @Dependency(\.analytics) var analytics

    // MARK: - Init

    public init() {}

    private enum CancelID: Hashable { case like(Int) }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.displayName = sessionClient.displayName()
                return load(&state)

            case .didTapRetry:
                return load(&state)

            case let .detailResponse(.success(detail)):
                state.detail = .loaded(detail)
                return .none

            case let .detailResponse(.failure(error)):
                if state.detail.value == nil {
                    state.detail = .failed(error.loadFailureMessage)
                }
                return .none

            case .didTapLike:
                guard let localLiked = state.detail.value?.isLiked else { return .none }
                // 표시값(overlay ?? 로컬)을 기준으로 뒤집어야 첫 탭이 헛돌지 않는다.
                let current = state.likeOverrides[state.policyId] ?? localLiked
                let newValue = !current
                setDetailLiked(&state, liked: newValue)
                let policyId = state.policyId
                return .merge(
                    likeEffect(id: state.policyId, liked: newValue) { .likeFailed(liked: newValue) },
                    .run { [analytics] _ in analytics.track(.likeToggle(policyId: policyId, liked: newValue, source: .detail)) }
                )

            case .didTapApply:
                guard let url = state.detail.value?.applyURL else { return .none }
                let policyId = state.policyId
                return .merge(
                    .run { [openURL] _ in _ = await openURL(url) },
                    .run { [analytics] _ in
                        analytics.track(.applyClick(policyId: policyId, applyURL: url.absoluteString, source: .detail))
                    }
                )

            case let .likeFailed(liked):
                // 그 사이 다른 화면이 overlay를 바꿨으면 덮지 않는다(내 낙관값이 남아있을 때만 롤백).
                setDetailLiked(&state, liked: !liked, writeOverlay: state.likeOverrides[state.policyId] == liked)
                return .none

            case let .didToggleRecommendationLike(section, id):
                guard let localLiked = recommendationLiked(state, section: section, id: id) else { return .none }
                // 표시값(overlay ?? 로컬)을 기준으로 뒤집어야 첫 탭이 헛돌지 않는다.
                let current = state.likeOverrides[id] ?? localLiked
                let newValue = !current
                setRecommendationLiked(&state, section: section, id: id, liked: newValue)
                return .merge(
                    likeEffect(id: id, liked: newValue) {
                        .recommendationLikeFailed(section: section, id: id, liked: newValue)
                    },
                    .run { [analytics] _ in analytics.track(.likeToggle(policyId: id, liked: newValue, source: .recommendation)) }
                )

            case let .recommendationLikeFailed(section, id, liked):
                // 그 사이 다른 화면이 overlay를 바꿨으면 덮지 않는다(내 낙관값이 남아있을 때만 롤백).
                setRecommendationLiked(&state, section: section, id: id, liked: !liked, writeOverlay: state.likeOverrides[id] == liked)
                return .none

            case .didTapShare:
                guard let detail = state.detail.value else { return .none }
                let content = PolicyShareContent(
                    policyId: detail.id,
                    title: detail.title,
                    description: "청바지에서 청년 정책을 확인해보세요!",
                    // 앱 복귀는 iosExecutionParams(policyId)로 처리하므로 webURL은 두지 않는다.
                    webURL: nil
                )
                return .merge(
                    .run { [policyDetailClient] _ in
                        try? await policyDetailClient.shareToKakao(content)
                    },
                    .run { [analytics] _ in analytics.track(.shareClick(policyId: detail.id)) }
                )

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private func load(_ state: inout State) -> Effect<Action> {
        if state.detail.isLoading || state.detail.value != nil { return .none }
        state.detail = .loading
        return .run { [policyDetailClient, policyId = state.policyId] send in
            do {
                let detail = try await policyDetailClient.fetch(policyId)
                await send(.detailResponse(.success(detail)))
            } catch {
                await send(.detailResponse(.failure(UseCaseError.map(error))))
            }
        }
    }

    private func likeEffect(id: Int, liked: Bool, onFailure: @escaping @Sendable () -> Action) -> Effect<Action> {
        .run { [policyLikeClient] send in
            do {
                try await policyLikeClient.setLike(id, liked)
            } catch {
                await send(onFailure())
            }
        }
        .cancellable(id: CancelID.like(id), cancelInFlight: true)
    }

    private func setDetailLiked(_ state: inout State, liked: Bool, writeOverlay: Bool = true) {
        if writeOverlay { state.$likeOverrides.withLock { $0[state.policyId] = liked } }
        guard var detail = state.detail.value else { return }
        detail.isLiked = liked
        state.detail = .loaded(detail)
    }

    private func recommendationLiked(_ state: State, section: RecommendationSection, id: Int) -> Bool? {
        guard let detail = state.detail.value else { return nil }
        switch section {
        case .personalized: return detail.personalized[id: id]?.isLiked
        case .popular: return detail.popular[id: id]?.isLiked
        }
    }

    private func setRecommendationLiked(_ state: inout State, section: RecommendationSection, id: Int, liked: Bool, writeOverlay: Bool = true) {
        if writeOverlay { state.$likeOverrides.withLock { $0[id] = liked } }
        guard var detail = state.detail.value else { return }
        switch section {
        case .personalized: detail.personalized[id: id]?.isLiked = liked
        case .popular: detail.popular[id: id]?.isLiked = liked
        }
        state.detail = .loaded(detail)
    }
}
