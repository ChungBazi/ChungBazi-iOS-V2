// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 한 줄(도메인 엔티티). `category`는 서버 원문 문자열이며,
/// UI 종류(아이콘·탭) 분류는 Presentation VO에서 파생한다.
public struct NotificationItem: Equatable, Sendable {
    public let id: Int
    public let category: String
    public let title: String
    public let message: String
    public let policyId: Int?
    public let isRead: Bool
    public let elapsedTime: String

    public init(
        id: Int,
        category: String,
        title: String,
        message: String,
        policyId: Int?,
        isRead: Bool,
        elapsedTime: String
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.message = message
        self.policyId = policyId
        self.isRead = isRead
        self.elapsedTime = elapsedTime
    }
}
