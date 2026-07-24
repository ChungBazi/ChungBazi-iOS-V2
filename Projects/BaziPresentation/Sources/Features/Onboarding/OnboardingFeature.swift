// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct OnboardingFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case didTapCompleteButton

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didCompleteOnboarding
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapCompleteButton:
                // TODO: 관심 정책 분야 설정(policyInterestSetup) 등 실제 온보딩 단계가 정해지면 그 흐름으로 교체.
                // OnboardingRoute(RouteReference)의 policyInterestSetup → onboardingComplete 순서를 참고.
                return .send(.delegate(.didCompleteOnboarding))

            case .delegate:
                return .none
            }
        }
    }
}
