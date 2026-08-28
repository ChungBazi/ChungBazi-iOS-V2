// Copyright © 2026 ChungBazi. All rights reserved.

/// 커서 페이지네이션 부기. 커서 타입만 다른 목록들이 공유한다.
/// (정책 목록은 `PaginationState<String>`, 알림은 `PaginationState<Int>`.)
public struct PaginationState<Cursor: Equatable & Sendable>: Equatable, Sendable {
    public var nextCursor: Cursor?
    public var hasNext: Bool
    public var isLoadingNext: Bool
    public var totalCount: Int

    public init(
        nextCursor: Cursor? =  nil,
        hasNext: Bool = false,
        isLoadingNext: Bool = false,
        totalCount: Int = 0
    ) {
        self.nextCursor = nextCursor
        self.hasNext = hasNext
        self.isLoadingNext = isLoadingNext
        self.totalCount = totalCount
    }

    /// 다음 페이지를 더 불러올 수 있는지(진행 중이 아니고 다음 커서가 남음).
    /// 커서가 없으면(hasNext가 true여도) 다음 페이지를 요청할 수 없다 — nil 커서로 1페이지가 재요청되는 것을 막는다.
    public var canLoadNext: Bool { hasNext && nextCursor != nil && !isLoadingNext }

    /// 1페이지 재조회 준비: 커서/플래그 초기화.
    public mutating func reset() {
        nextCursor = nil
        hasNext = false
        isLoadingNext = false
        totalCount = 0
    }

    /// 페이지 응답 반영(커서/다음 여부/총개수 갱신, 로딩 종료).
    public mutating func apply(nextCursor: Cursor?, hasNext: Bool, totalCount: Int = 0) {
        self.nextCursor = nextCursor
        self.hasNext = hasNext
        self.totalCount = totalCount
        self.isLoadingNext = false
    }
}

// MARK: - Page VO 편의 apply

extension PaginationState where Cursor == String {
    public mutating func apply(_ page: PolicyPageVO) {
        apply(nextCursor: page.nextCursor, hasNext: page.hasNext, totalCount: page.totalCount)
    }
}
