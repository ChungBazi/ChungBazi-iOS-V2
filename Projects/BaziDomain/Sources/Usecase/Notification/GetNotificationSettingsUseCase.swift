// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 설정을 조회한다.
public protocol GetNotificationSettingsUseCase: Sendable {
    func execute() async throws -> NotificationSettings
}
