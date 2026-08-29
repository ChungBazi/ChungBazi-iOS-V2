// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카드형 정책 목록(내 정책/캘린더/전체보기)이 공유하는 요약 모델.
public struct PolicySummary: Equatable, Identifiable, Sendable {
    public let id: Int
    public let category: PolicyCategory
    public let dDay: String
    public let title: String
    public let viewCount: Int
    public var isLiked: Bool
    /// 신청 마감일. 캘린더 표시/날짜별 필터링에 쓴다.
    public let deadlineDate: Date
    /// 상시모집(마감일 없음) 여부.
    public let isOpenEnded: Bool

    public init(
        id: Int,
        category: PolicyCategory,
        dDay: String,
        title: String,
        viewCount: Int,
        isLiked: Bool = true,
        deadlineDate: Date,
        isOpenEnded: Bool = false
    ) {
        self.id = id
        self.category = category
        self.dDay = dDay
        self.title = title
        self.viewCount = viewCount
        self.isLiked = isLiked
        self.deadlineDate = deadlineDate
        self.isOpenEnded = isOpenEnded
    }
}

// MARK: - Mock

extension PolicySummary {

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mockList: [PolicySummary] = [
        PolicySummary(id: 1, category: .job, dDay: "D-11", title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청년 디지털 직무역량 연계", viewCount: 15200, deadlineDate: date(2026, 5, 18)),
        PolicySummary(id: 2, category: .job, dDay: "D-11", title: "서울시 청년 일자리 인턴십", viewCount: 15200, deadlineDate: date(2026, 5, 18)),
        PolicySummary(id: 3, category: .job, dDay: "D-11", title: "청년 취업사관학교 디지털 신기술 인재 양성과정 모집", viewCount: 12400, deadlineDate: date(2026, 5, 18)),
        PolicySummary(id: 4, category: .dwelling, dDay: "D-5", title: "청년 맞춤형 주거복지 확대를 위한 전·월세 금융지원 및 월세 지원 사업", viewCount: 15200, deadlineDate: date(2026, 5, 12)),
        PolicySummary(id: 5, category: .dwelling, dDay: "D-14", title: "청년 1인가구 월세 특별지원 사업 신청 안내", viewCount: 10100, deadlineDate: date(2026, 5, 21)),
        PolicySummary(id: 6, category: .study, dDay: "D-20", title: "디지털·IT 실무 역량 강화를 위한 청년 취업사관학교 교육생 모집", viewCount: 9800, deadlineDate: date(2026, 5, 27)),
        PolicySummary(id: 7, category: .study, dDay: "D-9", title: "청년 자기계발 지원을 위한 온라인 강의 수강료 바우처", viewCount: 7200, deadlineDate: date(2026, 5, 16)),
        PolicySummary(id: 8, category: .livingSupport, dDay: "D-7", title: "청년 생활안정을 위한 필수생활비 바우처 지원 사업", viewCount: 7300, deadlineDate: date(2026, 5, 14)),
        PolicySummary(id: 9, category: .activity, dDay: "D-30", title: "청년 문화활동 지원을 위한 활동비 바우처 모집 공고", viewCount: 5100, deadlineDate: date(2026, 6, 6)),
        PolicySummary(id: 10, category: .job, dDay: "상시", title: "청년 창업 지원센터 상시 입주기업 모집", viewCount: 4300, deadlineDate: date(2026, 12, 31), isOpenEnded: true),
        PolicySummary(id: 11, category: .study, dDay: "상시", title: "청년 역량강화 프로그램 상시 모집", viewCount: 3100, deadlineDate: date(2026, 12, 31), isOpenEnded: true),
    ]
}
