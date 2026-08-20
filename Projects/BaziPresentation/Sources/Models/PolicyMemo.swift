// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 메모 화면(22번)이 쓰는 모델. `PolicyMemoResponseDTO`와 필드를 맞췄다.
public struct PolicyMemo: Equatable, Identifiable, Sendable {
    public let policyId: Int
    public let category: PolicyCategory
    public let dDay: String
    public let title: String
    public var memo: String

    public var id: Int { policyId }

    public init(policyId: Int, category: PolicyCategory, dDay: String, title: String, memo: String) {
        self.policyId = policyId
        self.category = category
        self.dDay = dDay
        self.title = title
        self.memo = memo
    }
}

// MARK: - Mock

extension PolicyMemo {

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static func mock(policyId: Int) -> PolicyMemo {
        PolicyMemo(
            policyId: policyId,
            category: .job,
            dDay: "D-11",
            title: "청년취업사관학교 모집",
            memo: ""
        )
    }
}
