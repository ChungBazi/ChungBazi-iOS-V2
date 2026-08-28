// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 목록 한 페이지를 조회한다. 탭 필터(category)·커서 페이지네이션 모두 서버가 처리한다.
public protocol FetchNotificationsUseCase: Sendable {
    func execute(category: String?, cursor: Int?, size: Int) async throws -> NotificationPage
}
