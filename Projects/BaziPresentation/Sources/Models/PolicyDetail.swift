// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세 화면(18번)이 쓰는 상세 정보 모델. `PolicyDetailResponseDTO`와 필드를 맞췄다.
public struct PolicyDetail: Equatable, Identifiable, Sendable {
    public let id: Int
    public let category: PolicyCategory
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

    public init(
        id: Int,
        category: PolicyCategory,
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
        referenceURLs: [String]
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
    }
}

// MARK: - Mock

extension PolicyDetail {

    // TODO: BaziDomain의 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static func mock(id: Int) -> PolicyDetail {
        PolicyDetail(
            id: id,
            category: .job,
            dDay: "D-11",
            title: "청년취업사관학교 모집",
            summary: "소속 근로자가 일·생활 균형을 위해 유연근무제를 활용하게 하는 중소, 중견기업에게 장려금을 지원해줘요",
            viewCount: 15200,
            eligibilityDescription: "- 연령: 20세 이상 40세 미만\n- 소득: 9분위\n- 추가신청자격: 없음",
            applyPeriod: "2024년 12월 9일 ~ 2025년 1월 31일",
            supportContent: """
            재택·원격근무제
            - 월 4일~7일 활용: 1개월 지급액 15만원
            - 월 8일 ~ 11일 활용 : 1개월 지급액 20만원
            - 월 12일 이상 활용 : 1개월 지급액 30만원
            - 최대지급액 : 360만원(1년간), 육아기 근로자는 2배 지원(최대 1년간 720만원)

            육아기 시차출퇴근제
            - 월 6일~11일 활용: 1개월 지급액 20만원
            - 월 12일 이상 활용: 1개월 지급액 40만원
            - 최대지급액 : 480만원(1년간)

            선택근무제
            - 월 30만원
            - 최대지급액 : 360만원(1년간), 육아기 근로자는 2배 지원(최대 1년간 720만원)
            """,
            applicationMethod: "접수처 : 신청인 본인 주민등록지 동 주민센터 (방문접수)",
            submittedDocument: "없음",
            screeningMethod: "서류 심사 후 개별 통보",
            referenceURLs: ["www.baro.com"]
        )
    }
}
