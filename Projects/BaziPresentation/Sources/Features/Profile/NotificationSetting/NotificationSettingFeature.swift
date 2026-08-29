// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 프로필 > 알림 설정.
/// 전체 알림은 마스터 스위치다: 끄면 하위 두 알림도 꺼지고 비활성화되며, 하위 두 알림을 모두 끄면 전체 알림도 꺼진다.
/// 토글은 로컬에 즉시 반영하고 서버에 저장한다(저장 실패는 무시하고 되돌리지 않는다 — 최근 검색어 저장 토글과 동일).
@Reducer
public struct NotificationSettingFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isAllNotificationOn: Bool
        public var isMyPolicyNotificationOn: Bool
        public var isChungBaziNotificationOn: Bool

        public init(
            isAllNotificationOn: Bool = true,
            isMyPolicyNotificationOn: Bool = true,
            isChungBaziNotificationOn: Bool = true
        ) {
            self.isAllNotificationOn = isAllNotificationOn
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

        // MARK: Internal
        case settingsResponse(Result<NotificationSettings, UseCaseError>)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {}

    // MARK: - Dependencies

    @Dependency(\.notificationSettingClient) var notificationSettingClient

    // MARK: - Init

    public init() {}

    // MARK: - CancelID

    private enum CancelID {
        case load
        case update
    }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [notificationSettingClient] send in
                    do {
                        let settings = try await notificationSettingClient.getSettings()
                        await send(.settingsResponse(.success(settings)))
                    } catch {
                        await send(.settingsResponse(.failure(UseCaseError.map(error))))
                    }
                }
                .cancellable(id: CancelID.load)

            case .settingsResponse(.success(let settings)):
                state.isAllNotificationOn = settings.isAllOn
                state.isMyPolicyNotificationOn = settings.isMyPolicyOn
                state.isChungBaziNotificationOn = settings.isChungBaziOn
                return .none

            case .settingsResponse(.failure):
                // TODO: 알림 설정 조회 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .didToggleAllNotification(let isOn):
                guard state.isAllNotificationOn != isOn else { return .none }
                state.isAllNotificationOn = isOn
                state.isMyPolicyNotificationOn = isOn
                state.isChungBaziNotificationOn = isOn
                return updateEffect(state)

            case .didToggleMyPolicyNotification(let isOn):
                guard state.isMyPolicyNotificationOn != isOn else { return .none }
                state.isMyPolicyNotificationOn = isOn
                syncAllFlag(&state)
                return updateEffect(state)

            case .didToggleChungBaziNotification(let isOn):
                guard state.isChungBaziNotificationOn != isOn else { return .none }
                state.isChungBaziNotificationOn = isOn
                syncAllFlag(&state)
                return updateEffect(state)

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    /// `전체=false`면 하위도 false여야 하는 서버 제약을 지키도록 전체 알림을 하위 상태에 맞춘다:
    /// 하위 중 하나라도 켜지면 전체 ON, 둘 다 꺼지면 전체 OFF.
    private func syncAllFlag(_ state: inout State) {
        state.isAllNotificationOn = state.isMyPolicyNotificationOn || state.isChungBaziNotificationOn
    }

    /// 현재 설정을 서버에 저장(실패는 무시, 되돌리지 않음). 진행 중인 로드는 취소해 낡은 응답이 덮어쓰지 않게 한다.
    private func updateEffect(_ state: State) -> Effect<Action> {
        let settings = NotificationSettings(
            isAllOn: state.isAllNotificationOn,
            isMyPolicyOn: state.isMyPolicyNotificationOn,
            isChungBaziOn: state.isChungBaziNotificationOn
        )
        return .merge(
            .cancel(id: CancelID.load),
            .run { [notificationSettingClient] _ in
                try? await notificationSettingClient.updateSettings(settings)
            }
            .cancellable(id: CancelID.update, cancelInFlight: true)
        )
    }
}
