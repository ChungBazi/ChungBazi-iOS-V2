// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 설정 조회/수정 통신을 담당한다. (알림 목록은 NotificationRepository 담당)
public protocol NotificationSettingRepository: Sendable {
    func getSettings() async throws -> NotificationSettings
    func updateSettings(_ settings: NotificationSettings) async throws
}
