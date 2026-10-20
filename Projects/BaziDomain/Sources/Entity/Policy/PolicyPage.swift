// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 커서 페이지네이션 정책 리스트 한 페이지.
public struct PolicyPage: Equatable, Sendable {
    public let policies: [PolicySummary]
    public let nextCursor: String?
    public let hasNext: Bool
    public let totalCount: Int

    public init(
        policies: [PolicySummary],
        nextCursor: String?,
        hasNext: Bool,
        totalCount: Int
    ) {
        self.policies = policies
        self.nextCursor = nextCursor
        self.hasNext = hasNext
        self.totalCount = totalCount
    }
}
