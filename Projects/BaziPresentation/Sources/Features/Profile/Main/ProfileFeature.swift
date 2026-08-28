// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct ProfileFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case infoEdit(ProfileInfoEditFeature)
        case nicknameEdit(NicknameEditFeature)
        case linkedAccounts(LinkedAccountsFeature)
        case withdraw(WithdrawFeature)
        case policyProfileEdit(PolicyProfileEditFeature)
        case notificationSetting(NotificationSettingFeature)
        case terms(TermsOfServiceFeature)
        case privacy(PrivacyPolicyFeature)
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()
        // TODO: BaziDomain의 내 프로필 조회 UseCase가 준비되면 UserAPI.getProfile 응답으로 교체한다.
        public var nickname = "김민재"

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didTapProfileHeader
        case didTapPolicyProfileRow
        case didTapNotificationSettingRow
        case didTapTermsRow
        case didTapPrivacyRow

        // MARK: Child
        case path(StackActionOf<Path>)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didLogout
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none

            case .didTapProfileHeader:
                state.path.append(.infoEdit(ProfileInfoEditFeature.State()))
                return .none

            case .didTapPolicyProfileRow:
                state.path.append(.policyProfileEdit(PolicyProfileEditFeature.State()))
                return .none

            case .didTapNotificationSettingRow:
                state.path.append(.notificationSetting(NotificationSettingFeature.State()))
                return .none

            case .didTapTermsRow:
                state.path.append(.terms(TermsOfServiceFeature.State()))
                return .none

            case .didTapPrivacyRow:
                state.path.append(.privacy(PrivacyPolicyFeature.State()))
                return .none

            case .path(.element(_, .infoEdit(.delegate(.nicknameEditRequested)))):
                state.path.append(.nicknameEdit(NicknameEditFeature.State(currentNickname: state.nickname)))
                return .none

            case .path(.element(_, .infoEdit(.delegate(.linkedAccountsRequested)))):
                state.path.append(.linkedAccounts(LinkedAccountsFeature.State()))
                return .none

            case .path(.element(_, .infoEdit(.delegate(.withdrawRequested)))):
                state.path.append(.withdraw(WithdrawFeature.State()))
                return .none

            case .path(.element(_, .nicknameEdit(.delegate(.didSaveNickname(let name))))):
                state.nickname = name
                return .none

            case .path(.element(_, .infoEdit(.delegate(.didLogout)))),
                 .path(.element(_, .withdraw(.delegate(.didCompleteWithdrawal)))):
                return .send(.delegate(.didLogout))

            case .path:
                return .none

            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension ProfileFeature.Path.State: Equatable {}
extension ProfileFeature.Path.Action: Equatable {}
