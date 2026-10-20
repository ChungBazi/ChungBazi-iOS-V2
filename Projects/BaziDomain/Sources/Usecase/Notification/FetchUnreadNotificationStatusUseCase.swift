// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 현재 사용자에게 읽지 않은 알림이 하나 이상 있는지 조회한다.
public protocol FetchUnreadNotificationStatusUseCase: Sendable {
    func execute() async throws -> Bool
}
