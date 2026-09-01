// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 목록 조회 Response DTO
public struct NotificationListResponseDTO: Decodable, Sendable {
    public let notifications: [NotificationItemDTO]
    // 마지막 페이지에서는 서버가 null을 준다.
    public let nextCursor: Int?
    public let hasNext: Bool
}

public struct NotificationItemDTO: Decodable, Sendable {
    public let notificationId: Int
    public let category: String
    public let title: String
    public let message: String
    public let policyId: Int?
    public let read: Bool
    public let elapsedTime: String
}
