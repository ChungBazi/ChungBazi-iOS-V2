// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension NotificationListResponseDTO {
    func toDomain() -> NotificationPage {
        NotificationPage(
            items: notifications.map { $0.toDomain() },
            nextCursor: nextCursor,
            hasNext: hasNext
        )
    }
}

extension NotificationItemDTO {
    func toDomain() -> NotificationItem {
        NotificationItem(
            id: notificationId,
            category: category,
            title: title,
            message: message,
            policyId: policyId,
            isRead: read,
            elapsedTime: elapsedTime
        )
    }
}
