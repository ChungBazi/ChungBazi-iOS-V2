// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 프로필 > 내 정보 수정(34). 로그아웃(31)은 별도 화면이 아니라 이 화면 위에 뜨는 확인 알럿이다.
@Reducer
public struct ProfileInfoEditFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var activeAlert: ActiveAlert?

        public init() {}
    }

    // MARK: - Alert

    public enum ActiveAlert: Equatable {
        case logout
        case withdraw
        case error
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case didTapNicknameEdit
        case didTapLinkedAccounts
        case didTapLogout
        case didCancelLogout
        case didConfirmLogout
        case didTapWithdraw
        case didCancelWithdraw
        case didConfirmWithdraw
        case didDismissError

        // MARK: Internal
        case didCompleteLogout
        case didFailLogout

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case nicknameEditRequested
        case linkedAccountsRequested
        case withdrawRequested
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
            case .didTapNicknameEdit:
                return .send(.delegate(.nicknameEditRequested))

            case .didTapLinkedAccounts:
                return .send(.delegate(.linkedAccountsRequested))

            case .didTapLogout:
                state.activeAlert = .logout
                return .none

            case .didCancelLogout:
                state.activeAlert = nil
                return .none

            case .didConfirmLogout:
                state.activeAlert = nil
                return .run { [sessionClient] send in
                    // 서버 로그아웃이 성공해야 로컬 세션을 초기화한다(logout 내부). 실패 시 에러 알럿.
                    do {
                        try await sessionClient.logout()
                        await send(.didCompleteLogout)
                    } catch {
                        await send(.didFailLogout)
                    }
                }

            case .didCompleteLogout:
                return .send(.delegate(.didLogout))

            case .didFailLogout:
                state.activeAlert = .error
                return .none

            case .didDismissError:
                state.activeAlert = nil
                return .none

            case .didTapWithdraw:
                state.activeAlert = .withdraw
                return .none

            case .didCancelWithdraw:
                state.activeAlert = nil
                return .none

            case .didConfirmWithdraw:
                state.activeAlert = nil
                return .send(.delegate(.withdrawRequested))

            case .delegate:
                return .none
            }
        }
    }
}
