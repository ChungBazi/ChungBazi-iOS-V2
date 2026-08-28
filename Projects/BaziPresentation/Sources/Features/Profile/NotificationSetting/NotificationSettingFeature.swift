// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 프로필 > 알림 설정(25).
/// 전체 알림 토글은 내 정책 알림/청바지 알림을 한 번에 켜고 끄는 마스터 스위치다.
@Reducer
public struct NotificationSettingFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isMyPolicyNotificationOn: Bool
        public var isChungBaziNotificationOn: Bool

        /// 두 알림이 모두 켜져 있을 때만 전체 알림도 켜진 것으로 본다.
        public var isAllNotificationOn: Bool {
            isMyPolicyNotificationOn && isChungBaziNotificationOn
        }

        public init(isMyPolicyNotificationOn: Bool = true, isChungBaziNotificationOn: Bool = true) {
            self.isMyPolicyNotificationOn = isMyPolicyNotificationOn
            self.isChungBaziNotificationOn = isChungBaziNotificationOn
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didToggleAllNotification(Bool)
        case didToggleMyPolicyNotification(Bool)
        case didToggleChungBaziNotification(Bool)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {}

    // MARK: - Dependencies

    // TODO: BaziDomain의 알림 설정 조회/수정 UseCase가 준비되면 추가
    // @Dependency(\.notificationSettingClient) var notificationSettingClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: notificationSettingClient가 준비되면 실제 서버 값으로 교체한다.
                return .none

            case .didToggleAllNotification(let isOn):
                state.isMyPolicyNotificationOn = isOn
                state.isChungBaziNotificationOn = isOn
                return .none

            case .didToggleMyPolicyNotification(let isOn):
                state.isMyPolicyNotificationOn = isOn
                return .none

            case .didToggleChungBaziNotification(let isOn):
                state.isChungBaziNotificationOn = isOn
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
