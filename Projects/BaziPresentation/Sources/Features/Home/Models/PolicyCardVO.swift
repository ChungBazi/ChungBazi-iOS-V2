// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// "맞춤정책 더보기" 플립카드(BZFlipCard)가 쓰는 카드뉴스 VO.
public struct PolicyCardVO: Equatable, Identifiable, Sendable {
    public let id: Int
    public let category: PolicyCategory
    public let dDay: String
    public let title: String
    /// 앞면 부제(한 줄 소개).
    public let summary: String
    public let applyPeriod: String
    /// 뒷면 지원 내용 원문.
    public let supportContent: String
    public let applyUrl: String?
    public var isBookmarked: Bool
    /// 온디바이스 AI 요약 상태. 뒷면이 .ready면 요약문, 그 외엔 원문 supportContent를 쓴다.
    public var aiSummary: CardSummaryState = .idle

    public init(
        id: Int,
        category: PolicyCategory,
        dDay: String,
        title: String,
        summary: String,
        applyPeriod: String,
        supportContent: String,
        applyUrl: String?,
        isBookmarked: Bool = false,
        aiSummary: CardSummaryState = .idle
    ) {
        self.id = id
        self.category = category
        self.dDay = dDay
        self.title = title
        self.summary = summary
        self.applyPeriod = applyPeriod
        self.supportContent = supportContent
        self.applyUrl = applyUrl
        self.isBookmarked = isBookmarked
        self.aiSummary = aiSummary
    }
}

// MARK: - CardSummaryState

/// 카드 뒷면 온디바이스 AI 요약의 생명주기.
public enum CardSummaryState: Equatable, Sendable {
    case idle          // 아직 요약 요청 전
    case loading       // 요약 생성 중
    case ready(String) // 요약 완료
    case unavailable   // 미지원/실패 → 원문 fallback

    /// 완료된 요약문(그 외 상태는 nil).
    public var text: String? {
        if case let .ready(text) = self { return text }
        return nil
    }

    public var isLoading: Bool { self == .loading }
}

// MARK: - Mapping (Domain → VO)

extension PolicyCardVO {
    public init(_ entity: PolicyCard) {
        // 서버 코드 → UI enum. 코드가 비어 있으면 categoryName 라벨로 복구를 시도한다.
        let category = entity.category.map(PolicyCategory.init(domain:))
            ?? PolicyCategory(rawValue: entity.categoryName)
            ?? .job
        self.init(
            id: entity.id,
            category: category,
            dDay: entity.dDay,
            title: entity.title,
            summary: entity.summary,
            applyPeriod: entity.applyPeriod,
            supportContent: entity.supportContent,
            applyUrl: entity.applyUrl,
            isBookmarked: entity.liked
        )
    }
}

// MARK: - Mock

extension PolicyCardVO {
    public static let mockList: [PolicyCardVO] = [
        PolicyCardVO(
            id: 1,
            category: .dwelling,
            dDay: "D-11",
            title: "청년 맞춤형 주거복지 확대를 위한 전·월세 금융지원 및 월세 지원 사업",
            summary: "소속 근로자가 일·생활 균형을 위해 유연근무제를 활용하게 하는 중소·중견기업에게 장려금을 지원",
            applyPeriod: "2025.05.03 - 2025.06.30",
            supportContent: "서울 청년취업사관학교는 청년들의 실무 역량 강화와 취업 연계를 지원하는 교육 프로그램입니다. 디지털·IT 분야 중심의 실무 교육과 프로젝트 기반 커리큘럼을 제공하며, 현직자 멘토링과 기업 연계 프로그램을 통해 취업 경쟁력을 높일 수 있도록 지원합니다.",
            applyUrl: "https://example.com"
        ),
        PolicyCardVO(
            id: 2,
            category: .job,
            dDay: "D-20",
            title: "청년 취업사관학교 디지털 신기술 인재 양성과정 모집",
            summary: "미취업 청년을 대상으로 실무 프로젝트 중심의 디지털 역량 교육을 제공",
            applyPeriod: "2025.06.01 - 2025.07.15",
            supportContent: "실무 중심의 프로젝트형 커리큘럼으로 디지털 신기술 역량을 키우고, 수료 후 채용 연계 및 취업 컨설팅까지 함께 제공하는 프로그램입니다.",
            applyUrl: "https://example.com"
        ),
        PolicyCardVO(
            id: 3,
            category: .study,
            dDay: "D-8",
            title: "청년 자기계발 지원을 위한 온라인 강의 수강료 바우처",
            summary: "자격증·어학·직무 관련 온라인 강의 수강료의 일부를 바우처로 지원",
            applyPeriod: "2025.05.20 - 2025.06.20",
            supportContent: "청년의 자기계발과 역량 강화를 돕기 위해 온라인 교육 플랫폼 수강료를 바우처 형태로 지원하는 사업입니다.",
            applyUrl: "https://example.com"
        ),
    ]

    public static let mock = mockList[0]
}
