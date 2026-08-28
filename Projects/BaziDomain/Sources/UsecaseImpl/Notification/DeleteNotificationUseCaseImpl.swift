// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct DeleteNotificationUseCaseImpl: DeleteNotificationUseCase {

    private let notificationRepository: NotificationRepository

    public init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    public func execute(notificationId: Int) async throws {
        try await notificationRepository.deleteNotification(notificationId: notificationId)
    }

    public func executeAll() async throws {
        try await notificationRepository.deleteAllNotifications()
    }
}
