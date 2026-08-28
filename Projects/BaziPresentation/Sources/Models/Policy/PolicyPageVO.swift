// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 커서 페이지네이션 정책 목록 한 페이지(Presentation VO).
public struct PolicyPageVO: Equatable, Sendable {
    public var policies: IdentifiedArrayOf<PolicySummaryVO>
    public var nextCursor: String?
    public var hasNext: Bool
    public var totalCount: Int

    public init(
        policies: IdentifiedArrayOf<PolicySummaryVO>,
        nextCursor: String?,
        hasNext: Bool,
        totalCount: Int
    ) {
        self.policies = policies
        self.nextCursor = nextCursor
        self.hasNext = hasNext
        self.totalCount = totalCount
    }

    public init(_ entity: PolicyPage) {
        self.init(
            policies: IdentifiedArray(uniqueElements: entity.policies.map(PolicySummaryVO.init)),
            nextCursor: entity.nextCursor,
            hasNext: entity.hasNext,
            totalCount: entity.totalCount
        )
    }
}
