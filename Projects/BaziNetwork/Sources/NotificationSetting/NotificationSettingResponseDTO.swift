// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 설정 조회 및 변경 Response DTO
public struct NotificationSettingResponseDTO: Decodable, Sendable {
    public let allNotificationEnabled: Bool
    public let policyNotificationEnabled: Bool
    public let chungbaziNotificationEnabled: Bool
}
