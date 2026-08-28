// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 정책 상세 화면 (18-1). 모든 정책 카드에서 진입하는 공용 화면이다.
@Reducer
public struct PolicyDetailFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable, Identifiable {
        public let policyId: Int
        public var detail: PolicyDetail?
        public var personalizedPolicies: IdentifiedArrayOf<PolicySummary>
        public var popularPolicies: IdentifiedArrayOf<PolicySummary>

        public var id: Int { policyId }

        public init(policyId: Int) {
            self.policyId = policyId
            self.detail = nil
            self.personalizedPolicies = []
            self.popularPolicies = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapLike
        case didTapShare
        case didTapApply
        case didToggleRecommendationLike(section: RecommendationSection, id: Int)
        case didTapPolicy(id: Int)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - RecommendationSection

    public enum RecommendationSection: Equatable {
        case personalized
        case popular
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 정책 UseCase가 준비되면 추가
    // @Dependency(\.policyClient) var policyClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: policyClient가 준비되면 PolicyDetailAPI.getPolicyDetail 응답으로 교체한다.
                state.detail = .mock(id: state.policyId)
                state.personalizedPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
                state.popularPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.suffix(2)))
                return .none

            case .didTapLike:
                state.detail?.isLiked.toggle()
                return .none

            case .didTapShare:
                // TODO: 공유 시트 연결
                return .none

            case .didTapApply:
                // TODO: 신청 외부 링크(ModalRoute.webView) 연결
                return .none

            case .didToggleRecommendationLike(let section, let id):
                switch section {
                case .personalized: state.personalizedPolicies[id: id]?.isLiked.toggle()
                case .popular: state.popularPolicies[id: id]?.isLiked.toggle()
                }
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }
}
