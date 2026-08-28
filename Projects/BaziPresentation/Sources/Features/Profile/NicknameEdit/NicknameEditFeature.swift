// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import BaziDomain
import ComposableArchitecture

/// 프로필 > 내 정보 수정 > 닉네임 수정(30). 저장에 성공해도 화면 이동 없이 토스트만 보여주고 현재 페이지를 유지한다.
@Reducer
public struct NicknameEditFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let currentNickname: String
        public var draftNickname: String
        public var isSaving = false
        public var isSuccessToastPresented = false

        public var isNicknameValid: Bool {
            let trimmed = draftNickname.trimmingCharacters(in: .whitespacesAndNewlines)
            return (BZInputField.defaultMinLength...BZInputField.defaultMaxLength).contains(trimmed.count)
        }

        /// 기존 닉네임에서 한 글자라도 바뀌어야 저장하기 버튼이 활성화된다.
        public var isSaveEnabled: Bool {
            isNicknameValid && draftNickname != currentNickname
        }

        public init(currentNickname: String) {
            self.currentNickname = currentNickname
            self.draftNickname = currentNickname
        }
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        // MARK: View
        case binding(BindingAction<State>)
        case didTapSaveButton

        // MARK: Internal
        case didSaveNickname
        case didFailToSaveNickname(UseCaseError)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSaveNickname(String)
    }

    // MARK: - Dependencies

    @Dependency(\.nicknameClient) var nicknameClient

    // MARK: - Init

    public init() {}

    // MARK: - CancelID

    private enum CancelID {
        case saveNickname
    }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none

            case .didTapSaveButton:
                guard state.isSaveEnabled, !state.isSaving else { return .none }
                state.isSaving = true
                let name = state.draftNickname.trimmingCharacters(in: .whitespacesAndNewlines)
                return .run { [nicknameClient] send in
                    do {
                        try await nicknameClient.setNickname(name)
                        await send(.didSaveNickname)
                    } catch {
                        await send(.didFailToSaveNickname(UseCaseError.map(error)))
                    }
                }
                .cancellable(id: CancelID.saveNickname, cancelInFlight: true)

            case .didSaveNickname:
                state.isSaving = false
                state.isSuccessToastPresented = true
                return .send(.delegate(.didSaveNickname(state.draftNickname)))

            case .didFailToSaveNickname:
                state.isSaving = false
                // TODO: 닉네임 저장 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
