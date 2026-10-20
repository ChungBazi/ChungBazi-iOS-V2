// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain

/// 정책 메모 화면(22)의 Presentation VO. 헤더(분야/dDay/제목) + 메모 본문.
public struct PolicyMemoVO: Equatable, Sendable {
    public let policyId: Int
    public let category: PolicyCategoryUI
    public let dDay: String
    public let title: String
    public var memo: String

    public init(
        policyId: Int,
        category: PolicyCategoryUI,
        dDay: String,
        title: String,
        memo: String
    ) {
        self.policyId = policyId
        self.category = category
        self.dDay = dDay
        self.title = title
        self.memo = memo
    }
}

// MARK: - Mapping

extension PolicyMemoVO {

    public init(_ entity: BaziDomain.PolicyMemo) {
        // 서버 코드 → UI enum. 코드가 비어 있으면(방어적) categoryName 라벨로 복구를 시도한다.
        let category = entity.category.map(PolicyCategoryUI.init(domain:))
            ?? PolicyCategoryUI(rawValue: entity.categoryName)
            ?? .job
        self.init(
            policyId: entity.policyId,
            category: category,
            dDay: entity.dDay,
            title: entity.title,
            memo: entity.memo
        )
    }
}

// MARK: - Mock

extension PolicyMemoVO {

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mock = PolicyMemoVO(
        policyId: 1,
        category: .job,
        dDay: "D-11",
        title: "2026 청년 디지털 직무역량 강화 지원 사업",
        memo: "3월 2일까지 서류 준비\n- 자기소개서\n- 주민등록등본"
    )
}
