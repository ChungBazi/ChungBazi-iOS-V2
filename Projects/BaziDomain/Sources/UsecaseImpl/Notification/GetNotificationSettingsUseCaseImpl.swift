// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct GetNotificationSettingsUseCaseImpl: GetNotificationSettingsUseCase {

    private let repository: NotificationSettingRepository

    public init(repository: NotificationSettingRepository) {
        self.repository = repository
    }

    public func execute() async throws -> NotificationSettings {
        try await repository.getSettings()
    }
}
