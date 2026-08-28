// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 커서 페이지네이션 알림 목록 한 페이지(도메인 엔티티).
public struct NotificationPage: Equatable, Sendable {
    public let items: [NotificationItem]
    public let nextCursor: Int?
    public let hasNext: Bool

    public init(items: [NotificationItem], nextCursor: Int?, hasNext: Bool) {
        self.items = items
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}
