// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

import BaziDomain

/// 정책 상세 화면 모델(Presentation VO). 추천 정책(맞춤/인기)도 함께 담는다.
public struct PolicyDetailVO: Equatable, Identifiable, Sendable {
    public let id: Int
    public let category: PolicyCategoryUI
    public let dDay: String
    public let title: String
    public let summary: String
    public let viewCount: Int
    public var isLiked: Bool
    public let eligibilityDescription: String
    public let applyPeriod: String
    public let supportContent: String
    public let applicationMethod: String
    public let submittedDocument: String
    public let screeningMethod: String
    public let referenceURLs: [String]
    public var personalized: IdentifiedArrayOf<PolicySummaryVO>
    public var popular: IdentifiedArrayOf<PolicySummaryVO>

    /// 신청 링크. 상세 응답에 별도 필드가 없어 참고 링크의 첫 항목을 사용한다.
    public var applyURL: URL? { referenceURLs.first.flatMap { URL(string: $0) } }

    public init(
        id: Int,
        category: PolicyCategoryUI,
        dDay: String,
        title: String,
        summary: String,
        viewCount: Int,
        isLiked: Bool = false,
        eligibilityDescription: String,
        applyPeriod: String,
        supportContent: String,
        applicationMethod: String,
        submittedDocument: String,
        screeningMethod: String,
        referenceURLs: [String],
        personalized: IdentifiedArrayOf<PolicySummaryVO> = [],
        popular: IdentifiedArrayOf<PolicySummaryVO> = []
    ) {
        self.id = id
        self.category = category
        self.dDay = dDay
        self.title = title
        self.summary = summary
        self.viewCount = viewCount
        self.isLiked = isLiked
        self.eligibilityDescription = eligibilityDescription
        self.applyPeriod = applyPeriod
        self.supportContent = supportContent
        self.applicationMethod = applicationMethod
        self.submittedDocument = submittedDocument
        self.screeningMethod = screeningMethod
        self.referenceURLs = referenceURLs
        self.personalized = personalized
        self.popular = popular
    }

    public init(_ entity: PolicyDetail) {
        let category = entity.category.map(PolicyCategoryUI.init(domain:))
            ?? PolicyCategoryUI(rawValue: entity.categoryName)
            ?? .job
        self.init(
            id: entity.id,
            category: category,
            dDay: entity.dDay,
            title: entity.title,
            summary: entity.summary,
            viewCount: entity.viewCount,
            isLiked: entity.liked,
            eligibilityDescription: entity.eligibilityDescription.orDash,
            applyPeriod: entity.applyPeriod.orDash,
            supportContent: entity.supportContent.orDash,
            applicationMethod: entity.applicationMethod.orDash,
            submittedDocument: entity.submittedDocument.orDash,
            screeningMethod: entity.screeningMethod.orDash,
            referenceURLs: entity.referenceUrls,
            personalized: IdentifiedArray(uniqueElements: entity.personalized.map(PolicySummaryVO.init)),
            popular: IdentifiedArray(uniqueElements: entity.popular.map(PolicySummaryVO.init))
        )
    }
}

// MARK: - Mock

extension PolicyDetailVO {

    public static func mock(id: Int) -> PolicyDetailVO {
        PolicyDetailVO(
            id: id,
            category: .job,
            dDay: "D-11",
            title: "청년취업사관학교 모집",
            summary: "",
            viewCount: 15200,
            eligibilityDescription: "- 연령: 20세 이상 40세 미만\n- 소득: 9분위\n- 추가신청자격: 없음",
            applyPeriod: "2024년 12월 9일 ~ 2025년 1월 31일",
            supportContent: "재택·원격근무제\n- 월 4일~7일 활용: 1개월 지급액 15만원",
            applicationMethod: "접수처 : 신청인 본인 주민등록지 동 주민센터 (방문접수)",
            submittedDocument: "없음",
            screeningMethod: "서류 심사 후 개별 통보",
            referenceURLs: ["https://www.gov.kr"],
            personalized: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(2))),
            popular: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.suffix(2)))
        )
    }
}

// MARK: - Empty → Placeholder

private extension String {
    /// 서버가 내용 없는 Q&A 항목을 null(→ 빈 문자열)로 내려주므로, 화면에서 바로 쓰도록 "-"로 대체한다.
    /// (summary는 비어 있으면 화면에서 숨기므로 이 변환을 적용하지 않는다.)
    var orDash: String { isEmpty ? "-" : self }
}
