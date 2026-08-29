// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 설정을 수정한다.
public protocol UpdateNotificationSettingsUseCase: Sendable {
    func execute(_ settings: NotificationSettings) async throws
}
