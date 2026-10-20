// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 메모 화면(22)의 도메인 모델. 정책 요약 정보 + 사용자가 작성한 메모 본문.
public struct PolicyMemo: Equatable, Sendable {
    public let policyId: Int
    public let category: PolicyCategory?
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let memo: String

    public init(
        policyId: Int,
        category: PolicyCategory?,
        categoryName: String,
        dDay: String,
        title: String,
        memo: String
    ) {
        self.policyId = policyId
        self.category = category
        self.categoryName = categoryName
        self.dDay = dDay
        self.title = title
        self.memo = memo
    }
}
