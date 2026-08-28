// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 목록 조회 및 읽음/삭제 통신을 담당한다.
public protocol NotificationRepository: Sendable {
    func fetchNotifications(category: String?, cursor: Int?, size: Int) async throws -> NotificationPage
    func deleteNotification(notificationId: Int) async throws
    func deleteAllNotifications() async throws
}
