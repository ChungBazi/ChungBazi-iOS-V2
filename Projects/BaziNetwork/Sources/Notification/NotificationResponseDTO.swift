// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 목록 조회 Response DTO
public struct NotificationListResponseDTO: Decodable {
    public let notifications: [NotificationItemDTO]
    public let nextCursor: Int
    public let hasNext: Bool
}

public struct NotificationItemDTO: Decodable {
    public let notificationId: Int
    public let category: String
    public let title: String
    public let message: String
    public let policyId: Int
    public let read: Bool
    public let elapsedTime: String
}

/// 알림 설정 조회 및 변경 Response DTO
public struct NotificationSettingResponseDTO: Decodable {
    public let allNotificationEnabled: Bool
    public let policyNotificationEnabled: Bool
    public let chungbaziNotificationEnabled: Bool
}
