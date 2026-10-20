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
        public var currentNickname = ""
        public var draftNickname = ""
        public var isSaving = false
        public var isSuccessToastPresented = false
        /// 저장 실패 시 표시할 경고 토스트 메시지(nil이면 미표시).
        public var errorToast: String?
        /// onAppear 초기화를 최초 1회만 수행하기 위한 플래그. (탭 전환 등으로 화면이 재등장할 때
        /// 입력 중이던 draftNickname이 세션 값으로 초기화되는 것을 막는다)
        public var hasLoaded = false

        /// 공백을 제거한 정규화 닉네임. 저장 요청·활성화 비교·성공 반영에 모두 이 값을 사용한다.
        public var normalizedNickname: String {
            draftNickname.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        public var isNicknameValid: Bool {
            (BZInputField.defaultMinLength...BZInputField.defaultMaxLength).contains(normalizedNickname.count)
        }

        /// 기존 닉네임에서 (공백 제거 기준) 한 글자라도 바뀌어야 저장하기 버튼이 활성화된다.
        public var isSaveEnabled: Bool {
            isNicknameValid && normalizedNickname != currentNickname
        }

        public init() {}
    }

    // MARK: - Action

    public enum Action: BindableAction, Equatable {
        // MARK: View
        case onAppear
        case binding(BindingAction<State>)
        case didTapSaveButton

        // MARK: Internal
        case didSaveNickname(String)
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
    @Dependency(\.sessionClient) var sessionClient

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
            case .onAppear:
                // 재등장(탭 전환 등) 시 입력 중이던 값이 세션 값으로 초기화되지 않도록 최초 1회만 로드한다.
                guard !state.hasLoaded else { return .none }
                state.hasLoaded = true
                let name = sessionClient.userName() ?? ""
                state.currentNickname = name
                state.draftNickname = name
                return .none

            case .binding:
                return .none

            case .didTapSaveButton:
                guard state.isSaveEnabled, !state.isSaving else { return .none }
                state.isSaving = true
                let name = state.normalizedNickname
                return .run { [nicknameClient] send in
                    do {
                        try await nicknameClient.setNickname(name)
                        await send(.didSaveNickname(name))
                    } catch {
                        await send(.didFailToSaveNickname(UseCaseError.map(error)))
                    }
                }
                .cancellable(id: CancelID.saveNickname, cancelInFlight: true)

            case .didSaveNickname(let name):
                state.isSaving = false
                state.currentNickname = name
                state.draftNickname = name
                state.isSuccessToastPresented = true
                return .send(.delegate(.didSaveNickname(name)))

            case .didFailToSaveNickname(let error):
                state.isSaving = false
                state.errorToast = error.loadFailureMessage
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
