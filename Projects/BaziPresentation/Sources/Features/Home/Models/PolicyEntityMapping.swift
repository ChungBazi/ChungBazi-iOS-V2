// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

// MARK: - PolicyCategory (Domain → Presentation)

extension PolicyCategory {

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

// MARK: - PolicySummary (Domain → Presentation VO)

extension PolicySummary {

    init(_ entity: BaziDomain.PolicySummary) {
        // 서버 코드 → UI enum. 코드가 비어 있으면(방어적) categoryName 라벨로 복구를 시도한다.
        let category = entity.category.map(PolicyCategory.init(domain:))
            ?? PolicyCategory(rawValue: entity.categoryName)
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
        func map(_ list: [BaziDomain.PolicySummary]) -> IdentifiedArrayOf<PolicySummary> {
            IdentifiedArray(uniqueElements: list.map(PolicySummary.init))
        }
        self.init(
            userName: entity.userName,
            hasUnreadNotification: entity.hasUnreadNotification,
            personalized: map(entity.personalized),
            recentViewed: map(entity.recentViewed),
            popular: map(entity.popular),
            deadline: map(entity.upcomingDeadline),
            newest: map(entity.latest)
        )
    }
}
