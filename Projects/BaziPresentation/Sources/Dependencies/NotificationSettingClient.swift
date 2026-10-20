// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct NotificationSettingClient: Sendable {
    public var getSettings: @Sendable () async throws -> NotificationSettings
    public var updateSettings: @Sendable (_ settings: NotificationSettings) async throws -> Void
}

extension NotificationSettingClient: TestDependencyKey {
    public static let testValue = NotificationSettingClient()

    public static let previewValue = NotificationSettingClient(
        getSettings: { NotificationSettings(isAllOn: true, isMyPolicyOn: true, isChungBaziOn: true) },
        updateSettings: { _ in }
    )
}

extension DependencyValues {
    public var notificationSettingClient: NotificationSettingClient {
        get { self[NotificationSettingClient.self] }
        set { self[NotificationSettingClient.self] = newValue }
    }
}
