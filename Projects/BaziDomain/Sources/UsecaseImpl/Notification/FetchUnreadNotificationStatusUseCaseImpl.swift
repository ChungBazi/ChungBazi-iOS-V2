// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchUnreadNotificationStatusUseCaseImpl: FetchUnreadNotificationStatusUseCase {

    private let notificationRepository: NotificationRepository

    public init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    public func execute() async throws -> Bool {
        try await notificationRepository.fetchUnreadStatus()
    }
}
