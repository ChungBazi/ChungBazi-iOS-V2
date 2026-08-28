// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 프로필 > 내 정보 수정(34). 로그아웃(31)은 별도 화면이 아니라 이 화면 위에 뜨는 확인 알럿이다.
@Reducer
public struct ProfileInfoEditFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isLogoutAlertPresented = false
        public var isWithdrawAlertPresented = false

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didTapNicknameEdit
        case didTapLinkedAccounts
        case didTapLogout
        case didCancelLogout
        case didConfirmLogout
        case didTapWithdraw
        case didCancelWithdraw
        case didConfirmWithdraw

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didTapNicknameEdit
        case didTapLinkedAccounts
        case didTapWithdraw
        case didLogout
    }

    // MARK: - Dependencies

    @Dependency(\.sessionClient) var sessionClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .didTapNicknameEdit:
                return .send(.delegate(.didTapNicknameEdit))

            case .didTapLinkedAccounts:
                return .send(.delegate(.didTapLinkedAccounts))

            case .didTapLogout:
                state.isLogoutAlertPresented = true
                return .none

            case .didCancelLogout:
                state.isLogoutAlertPresented = false
                return .none

            case .didConfirmLogout:
                state.isLogoutAlertPresented = false
                sessionClient.resetSession()
                return .send(.delegate(.didLogout))

            case .didTapWithdraw:
                state.isWithdrawAlertPresented = true
                return .none

            case .didCancelWithdraw:
                state.isWithdrawAlertPresented = false
                return .none

            case .didConfirmWithdraw:
                state.isWithdrawAlertPresented = false
                return .send(.delegate(.didTapWithdraw))

            case .delegate:
                return .none
            }
        }
    }
}
