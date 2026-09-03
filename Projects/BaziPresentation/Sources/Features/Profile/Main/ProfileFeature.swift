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
        public var nickname = ""
        public var isUpdateAvailable = false

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
        case didTapInquiry
        case didTapAppStore

        // MARK: Child
        case path(StackActionOf<Path>)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didLogout
    }

    // MARK: - Dependencies

    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.openURL) var openURL
    @Dependency(\.appConfigClient) var appConfigClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.nickname = sessionClient.displayName()
                state.isUpdateAvailable = appConfigClient.isUpdateAvailable()
                return .none

            case .didTapInquiry:
                guard let url = ProfileConstants.inquiryFormURL else { return .none }
                return .run { [openURL] _ in _ = await openURL(url) }

            case .didTapAppStore:
                guard let url = ProfileConstants.appStoreURL else { return .none }
                return .run { [openURL] _ in _ = await openURL(url) }

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
                state.path.append(.nicknameEdit(NicknameEditFeature.State()))
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
