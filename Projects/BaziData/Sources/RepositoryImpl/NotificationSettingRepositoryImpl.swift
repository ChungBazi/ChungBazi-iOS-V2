// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct NotificationSettingRepositoryImpl: NotificationSettingRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func getSettings() async throws -> NotificationSettings {
        let dto: NotificationSettingResponseDTO = try await networkProvider.request(NotificationSettingAPI.getSettings)
        return dto.toEntity()
    }

    public func updateSettings(_ settings: NotificationSettings) async throws {
        let body = NotificationSettingUpdateRequestDTO(
            allNotificationEnabled: settings.isAllOn,
            policyNotificationEnabled: settings.isMyPolicyOn,
            chungbaziNotificationEnabled: settings.isChungBaziOn
        )
        try await networkProvider.requestStatusCode(NotificationSettingAPI.updateSettings(body: body))
    }
}
