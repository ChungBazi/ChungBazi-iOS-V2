// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension NotificationSettingResponseDTO {
    func toEntity() -> NotificationSettings {
        NotificationSettings(
            isAllOn: allNotificationEnabled,
            isMyPolicyOn: policyNotificationEnabled,
            isChungBaziOn: chungbaziNotificationEnabled
        )
    }
}
