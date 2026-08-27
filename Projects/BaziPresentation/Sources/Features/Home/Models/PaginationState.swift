// Copyright © 2026 ChungBazi. All rights reserved.

/// 커서 페이지네이션 부기(簿記). 랭킹·분야별 목록이 공유한다.
public struct PaginationState: Equatable, Sendable {
    public var nextCursor: String?
    public var hasNext: Bool
    public var isLoadingNext: Bool
    public var totalCount: Int

    public init(
        nextCursor: String? = nil,
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
    public var canLoadNext: Bool { hasNext && !isLoadingNext }

    /// 1페이지 재조회 준비: 커서/플래그 초기화.
    public mutating func reset() {
        nextCursor = nil
        hasNext = false
        isLoadingNext = false
        totalCount = 0
    }

    /// 페이지 응답 반영(커서/다음 여부/총개수 갱신, 로딩 종료).
    public mutating func apply(_ page: PolicyPageVO) {
        nextCursor = page.nextCursor
        hasNext = page.hasNext
        totalCount = page.totalCount
        isLoadingNext = false
    }
}
