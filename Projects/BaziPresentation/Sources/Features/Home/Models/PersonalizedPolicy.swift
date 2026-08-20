// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// "맞춤정책 더보기" 뒤집기 카드(BZFlipCard)가 쓰는, 상세 설명이 포함된 정책 모델.
public struct PersonalizedPolicy: Equatable, Identifiable, Sendable {
    public let id: Int
    public let category: PolicyCategory
    public let dDay: String
    public let title: String
    public let subtitle: String
    public let applyPeriod: String
    public let description: String
    public var isBookmarked: Bool

    public init(
        id: Int,
        category: PolicyCategory,
        dDay: String,
        title: String,
        subtitle: String,
        applyPeriod: String,
        description: String,
        isBookmarked: Bool = false
    ) {
        self.id = id
        self.category = category
        self.dDay = dDay
        self.title = title
        self.subtitle = subtitle
        self.applyPeriod = applyPeriod
        self.description = description
        self.isBookmarked = isBookmarked
    }
}

// MARK: - Mock

extension PersonalizedPolicy {

    // TODO: BaziDomain의 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mockList: [PersonalizedPolicy] = [
        PersonalizedPolicy(
            id: 1,
            category: .dwelling,
            dDay: "D-11",
            title: "청년 맞춤형 주거복지 확대를 위한 전·월세 금융지원 및 월세 지원 사업",
            subtitle: "소속 근로자가 일·생활 균형을 위해 유연근무제를 활용하게 하는 중소, 중견기업에게 장려금을 지원",
            applyPeriod: "2025.05.03 - 2025.06.30",
            description: "서울 청년취업사관학교는 청년들의 실무 역량 강화와 취업 연계를 지원하는 교육 프로그램입니다. 디지털·IT 분야 중심의 실무 교육과 프로젝트 기반 커리큘럼을 제공하며, 현직자 멘토링과 기업 연계 프로그램을 통해 취업 경쟁력을 높일 수 있도록 지원합니다."
        ),
        PersonalizedPolicy(
            id: 2,
            category: .job,
            dDay: "D-20",
            title: "청년 취업사관학교 디지털 신기술 인재 양성과정 모집",
            subtitle: "미취업 청년을 대상으로 실무 프로젝트 중심의 디지털 역량 교육을 제공",
            applyPeriod: "2025.06.01 - 2025.07.15",
            description: "실무 중심의 프로젝트형 커리큘럼으로 디지털 신기술 역량을 키우고, 수료 후 채용 연계 및 취업 컨설팅까지 함께 제공하는 프로그램입니다."
        ),
        PersonalizedPolicy(
            id: 3,
            category: .study,
            dDay: "D-8",
            title: "청년 자기계발 지원을 위한 온라인 강의 수강료 바우처",
            subtitle: "자격증·어학·직무 관련 온라인 강의 수강료의 일부를 바우처로 지원",
            applyPeriod: "2025.05.20 - 2025.06.20",
            description: "청년의 자기계발과 역량 강화를 돕기 위해 온라인 교육 플랫폼 수강료를 바우처 형태로 지원하는 사업입니다."
        ),
    ]
}
