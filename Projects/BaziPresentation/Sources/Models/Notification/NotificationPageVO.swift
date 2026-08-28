// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 커서 페이지네이션 알림 목록 한 페이지(Presentation VO).
public struct NotificationPageVO: Equatable, Sendable {
    public var items: IdentifiedArrayOf<NotificationItemVO>
    public var nextCursor: Int?
    public var hasNext: Bool

    public init(
        items: IdentifiedArrayOf<NotificationItemVO>,
        nextCursor: Int?,
        hasNext: Bool
    ) {
        self.items = items
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }

    public init(_ entity: NotificationPage) {
        self.init(
            items: IdentifiedArray(uniqueElements: entity.items.map(NotificationItemVO.init)),
            nextCursor: entity.nextCursor,
            hasNext: entity.hasNext
        )
    }
}

// MARK: - Mock

extension NotificationPageVO {

    public static let mock = NotificationPageVO(
        items: IdentifiedArray(uniqueElements: NotificationItemVO.mockList),
        nextCursor: nil,
        hasNext: false
    )
}

// MARK: - PaginationState 편의 apply (Int 커서)

extension PaginationState where Cursor == Int {
    public mutating func apply(_ page: NotificationPageVO) {
        apply(nextCursor: page.nextCursor, hasNext: page.hasNext)
    }
}
