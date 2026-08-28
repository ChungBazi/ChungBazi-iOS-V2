// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct NotificationRepositoryImpl: NotificationRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func fetchNotifications(category: String?, cursor: Int?, size: Int) async throws -> NotificationPage {
        let dto: NotificationListResponseDTO = try await networkProvider.request(
            NotificationAPI.getNotifications(category: category, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func deleteNotification(notificationId: Int) async throws {
        try await networkProvider.requestStatusCode(NotificationAPI.deleteNotification(notificationId: notificationId))
    }

    public func deleteAllNotifications() async throws {
        try await networkProvider.requestStatusCode(NotificationAPI.deleteAllNotifications)
    }
}
