// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct OnboardingCompleteFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let nickname: String

        public init(nickname: String) {
            self.nickname = nickname
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case didTapConfirmButton

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didTapConfirm
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapConfirmButton:
                return .send(.delegate(.didTapConfirm))

            case .delegate:
                return .none
            }
        }
    }
}
