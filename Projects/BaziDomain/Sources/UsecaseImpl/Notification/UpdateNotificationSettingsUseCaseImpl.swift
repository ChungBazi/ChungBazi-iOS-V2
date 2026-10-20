// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct UpdateNotificationSettingsUseCaseImpl: UpdateNotificationSettingsUseCase {

    private let repository: NotificationSettingRepository

    public init(repository: NotificationSettingRepository) {
        self.repository = repository
    }

    public func execute(_ settings: NotificationSettings) async throws {
        try await repository.updateSettings(settings)
    }
}
