// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import BaziDomain
import ComposableArchitecture

@Reducer
public struct NicknameSetupFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var nickname = ""
        public var isSaving = false
        /// 저장 실패 시 표시할 경고 토스트 메시지(nil이면 미표시).
        public var errorToast: String?

        public var isNicknameValid: Bool {
            let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
            return (BZInputField.defaultMinLength...BZInputField.defaultMaxLength).contains(trimmed.count)
        }

        public init() {}
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        // MARK: View
        case binding(BindingAction<State>)
        case didTapConfirmButton

        // MARK: Internal
        case didSetNickname
        case didFailToSetNickname(UseCaseError)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSetNickname
    }

    // MARK: - Dependencies

    @Dependency(\.nicknameClient) var nicknameClient

    // MARK: - Init

    public init() {}

    // MARK: - CancelID

    private enum CancelID {
        case setNickname
    }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .didTapConfirmButton:
                guard state.isNicknameValid, !state.isSaving else { return .none }
                state.isSaving = true
                let name = state.nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                return .run { [nicknameClient] send in
                    do {
                        try await nicknameClient.setNickname(name)
                        await send(.didSetNickname)
                    } catch {
                        await send(.didFailToSetNickname(UseCaseError.map(error)))
                    }
                }
                .cancellable(id: CancelID.setNickname, cancelInFlight: true)

            case .didSetNickname:
                state.isSaving = false
                return .send(.delegate(.didSetNickname))

            case .didFailToSetNickname(let error):
                state.isSaving = false
                state.errorToast = error.loadFailureMessage
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
