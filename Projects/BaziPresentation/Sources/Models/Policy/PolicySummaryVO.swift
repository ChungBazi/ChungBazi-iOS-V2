// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain

/// 홈의 카드형 정책 목록(최근 본/인기/마감임박/새로 뜬/분야별)이 공유하는 요약 모델.
public struct PolicySummaryVO: Equatable, Identifiable, Sendable {
    public let id: Int
    public let category: PolicyCategoryUI
    public let dDay: String
    public let title: String
    public let viewCount: Int
    public var isLiked: Bool

    public init(
        id: Int,
        category: PolicyCategoryUI,
        dDay: String,
        title: String,
        viewCount: Int,
        isLiked: Bool = false
    ) {
        self.id = id
        self.category = category
        self.dDay = dDay
        self.title = title
        self.viewCount = viewCount
        self.isLiked = isLiked
    }
}

// MARK: - Mapping

extension PolicySummaryVO {

    public init(_ entity: BaziDomain.PolicySummary) {
        // 서버 코드 → UI enum. 코드가 비어 있으면(방어적) categoryName 라벨로 복구를 시도한다.
        let category = entity.category.map(PolicyCategoryUI.init(domain:))
            ?? PolicyCategoryUI(rawValue: entity.categoryName)
            ?? .job
        self.init(
            id: entity.id,
            category: category,
            dDay: entity.dDay,
            title: entity.title,
            viewCount: entity.viewCount,
            isLiked: entity.liked
        )
    }
}

// MARK: - Mock

extension PolicySummaryVO {

    // TODO: BaziDomain의 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mockList: [PolicySummaryVO] = [
        PolicySummaryVO(id: 1, category: .job, dDay: "D-11", title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청년 디지털 직무역량 연계", viewCount: 15200),
        PolicySummaryVO(id: 2, category: .job, dDay: "D-18", title: "청년 취업사관학교 디지털 신기술 인재 양성과정 모집", viewCount: 12400),
        PolicySummaryVO(id: 3, category: .job, dDay: "D-3", title: "중소기업 청년 채용연계형 인턴십 지원 사업", viewCount: 8600),
        PolicySummaryVO(id: 4, category: .dwelling, dDay: "D-5", title: "청년 맞춤형 주거복지 확대를 위한 전·월세 금융지원 및 월세 지원 사업", viewCount: 15200),
        PolicySummaryVO(id: 5, category: .dwelling, dDay: "D-14", title: "청년 1인가구 월세 특별지원 사업 신청 안내", viewCount: 10100),
        PolicySummaryVO(id: 6, category: .dwelling, dDay: "D-25", title: "전세보증금 반환보증료 지원 사업", viewCount: 6400),
        PolicySummaryVO(id: 7, category: .study, dDay: "D-20", title: "디지털·IT 실무 역량 강화를 위한 청년 취업사관학교 교육생 모집", viewCount: 9800),
        PolicySummaryVO(id: 8, category: .study, dDay: "D-9", title: "청년 자기계발 지원을 위한 온라인 강의 수강료 바우처", viewCount: 7200),
        PolicySummaryVO(id: 9, category: .study, dDay: "D-40", title: "국가기술자격증 취득 지원금 신청 안내", viewCount: 4100),
        PolicySummaryVO(id: 10, category: .livingSupport, dDay: "D-7", title: "청년 생활안정을 위한 필수생활비 바우처 지원 사업", viewCount: 7300),
        PolicySummaryVO(id: 11, category: .livingSupport, dDay: "D-16", title: "청년 마음건강 상담비 지원 사업", viewCount: 5900),
        PolicySummaryVO(id: 12, category: .livingSupport, dDay: "D-2", title: "청년 교통비 지원 바우처 신청 안내", viewCount: 11200),
        PolicySummaryVO(id: 13, category: .activity, dDay: "D-30", title: "청년 문화활동 지원을 위한 활동비 바우처 모집 공고", viewCount: 5100),
        PolicySummaryVO(id: 14, category: .activity, dDay: "D-12", title: "청년 해외 교류 프로그램 참가자 모집", viewCount: 6800),
        PolicySummaryVO(id: 15, category: .activity, dDay: "D-45", title: "청년 동아리 활동비 지원 사업 안내", viewCount: 3400),
    ]
}
