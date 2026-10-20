// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchNotificationsUseCaseImpl: FetchNotificationsUseCase {

    private let notificationRepository: NotificationRepository

    public init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    public func execute(category: String?, cursor: Int?, size: Int) async throws -> NotificationPage {
        try await notificationRepository.fetchNotifications(category: category, cursor: cursor, size: size)
    }
}
