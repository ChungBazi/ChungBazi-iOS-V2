// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct OnboardingStartFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case onboardingContainer(OnboardingContainerFeature)
        case onboardingComplete(OnboardingCompleteFeature)
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case didTapStartButton

        // MARK: Child
        case path(StackActionOf<Path>)

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
            case .didTapStartButton:
                state.path.append(.onboardingContainer(OnboardingContainerFeature.State()))
                return .none

            case .path(.element(id: _, action: .onboardingContainer(.delegate(.didTapPrevious)))):
                state.path.removeLast()
                return .none

            case .path(.element(id: _, action: .onboardingContainer(.delegate(.didCompleteAllSteps)))):
                state.path.append(.onboardingComplete(OnboardingCompleteFeature.State()))
                return .none

            case .path(.element(id: _, action: .onboardingComplete(.delegate(.didTapConfirm)))):
                return .send(.delegate(.didCompleteOnboarding))

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension OnboardingStartFeature.Path.State: Equatable {}
