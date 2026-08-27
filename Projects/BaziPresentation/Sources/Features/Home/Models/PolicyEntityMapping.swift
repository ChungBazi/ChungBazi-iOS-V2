// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

// MARK: - PolicyCategoryUI (Domain → Presentation)

extension PolicyCategoryUI {

    /// 서버 카테고리 코드(Domain enum)를 화면용 카테고리(UI enum)로 1:1 변환한다.
    init(domain: BaziDomain.PolicyCategory) {
        switch domain {
        case .jobStartup:  self = .job
        case .housing:     self = .dwelling
        case .growth:      self = .study
        case .lifeSupport: self = .livingSupport
        case .activity:    self = .activity
        }
    }
}

// MARK: - PolicyCategoryUI (Presentation → Domain)

extension PolicyCategoryUI {

    /// UI 카테고리 → 서버 카테고리 코드(요청 파라미터용).
    public func toDomain() -> BaziDomain.PolicyCategory {
        switch self {
        case .job:           return .jobStartup
        case .dwelling:      return .housing
        case .study:         return .growth
        case .livingSupport: return .lifeSupport
        case .activity:      return .activity
        }
    }
}

// MARK: - PolicySummaryVO (Domain → Presentation VO)

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
            isBookmarked: entity.liked
        )
    }
}

// MARK: - HomeFeedVO (Domain → Presentation VO)

extension HomeFeedVO {

    public init(_ entity: HomeFeed) {
        func map(_ list: [BaziDomain.PolicySummary]) -> IdentifiedArrayOf<PolicySummaryVO> {
            IdentifiedArray(uniqueElements: list.map(PolicySummaryVO.init))
        }
        self.init(
            hasUnreadNotification: entity.hasUnreadNotification,
            personalized: map(entity.personalized),
            recentViewed: map(entity.recentViewed),
            popular: map(entity.popular),
            deadline: map(entity.upcomingDeadline),
            newest: map(entity.latest)
        )
    }
}
