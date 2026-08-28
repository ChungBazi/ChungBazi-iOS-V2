// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림을 삭제한다. 단건 삭제와 전체 삭제를 함께 담당한다.
public protocol DeleteNotificationUseCase: Sendable {
    func execute(notificationId: Int) async throws
    func executeAll() async throws
}
