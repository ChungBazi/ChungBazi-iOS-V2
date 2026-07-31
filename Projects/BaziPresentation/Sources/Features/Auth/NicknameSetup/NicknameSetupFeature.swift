// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import ComposableArchitecture

@Reducer
public struct NicknameSetupFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var nickname = ""

        public var isNicknameValid: Bool {
            (BZInputField.defaultMinLength...BZInputField.defaultMaxLength).contains(nickname.count)
        }

        public init() {}
    }

    // MARK: - Action

    public enum Action: BindableAction {
        // MARK: View
        case binding(BindingAction<State>)
        case didTapConfirmButton

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSetNickname
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 유저 UseCase가 준비되면 추가
    // @Dependency(\.userClient) var userClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .didTapConfirmButton:
                // TODO: userClient가 준비되면 닉네임 저장 요청 후 delegate로 교체.
                return .send(.delegate(.didSetNickname))

            case .delegate:
                return .none
            }
        }
    }
}
