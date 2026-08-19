// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 설정 변경 Request DTO
public struct NotificationSettingUpdateRequestDTO: Encodable {
    public let allNotificationEnabled: Bool
    public let policyNotificationEnabled: Bool
    public let chungbaziNotificationEnabled: Bool

    public init(
        allNotificationEnabled: Bool,
        policyNotificationEnabled: Bool,
        chungbaziNotificationEnabled: Bool
    ) {
        self.allNotificationEnabled = allNotificationEnabled
        self.policyNotificationEnabled = policyNotificationEnabled
        self.chungbaziNotificationEnabled = chungbaziNotificationEnabled
    }
}
