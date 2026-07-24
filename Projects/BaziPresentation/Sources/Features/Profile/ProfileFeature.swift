// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct ProfileFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
