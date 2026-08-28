// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 홈 메인 화면이 한 번에 그리는 섹션별 정책 묶음(Presentation VO).
/// userName은 세션 상태이므로 여기 담지 않고 SessionClient에서 읽는다.
public struct HomeFeedVO: Equatable, Sendable {
    public var hasUnreadNotification: Bool
    public var personalized: IdentifiedArrayOf<PolicySummaryVO>
    public var recentViewed: IdentifiedArrayOf<PolicySummaryVO>
    public var popular: IdentifiedArrayOf<PolicySummaryVO>
    public var deadline: IdentifiedArrayOf<PolicySummaryVO>
    public var newest: IdentifiedArrayOf<PolicySummaryVO>

    public init(
        hasUnreadNotification: Bool,
        personalized: IdentifiedArrayOf<PolicySummaryVO>,
        recentViewed: IdentifiedArrayOf<PolicySummaryVO>,
        popular: IdentifiedArrayOf<PolicySummaryVO>,
        deadline: IdentifiedArrayOf<PolicySummaryVO>,
        newest: IdentifiedArrayOf<PolicySummaryVO>
    ) {
        self.hasUnreadNotification = hasUnreadNotification
        self.personalized = personalized
        self.recentViewed = recentViewed
        self.popular = popular
        self.deadline = deadline
        self.newest = newest
    }
}

// MARK: - Like

extension HomeFeedVO {

    /// 모든 섹션에서 해당 정책의 찜 상태를 갱신한다.
    /// 같은 정책이 여러 섹션(맞춤·인기 등)에 겹쳐 나올 수 있어, 한 섹션만 바꾸면 하트가 어긋난다.
    public mutating func setLiked(id: Int, liked: Bool) {
        personalized[id: id]?.isLiked = liked
        recentViewed[id: id]?.isLiked = liked
        popular[id: id]?.isLiked = liked
        deadline[id: id]?.isLiked = liked
        newest[id: id]?.isLiked = liked
    }
}

// MARK: - Mapping

extension HomeFeedVO {

    public init(_ entity: HomeFeed) {
        func map(_ list: [BaziDomain.PolicySummary]) -> IdentifiedArrayOf<PolicySummaryVO> {
            IdentifiedArray(deduplicating: list.map(PolicySummaryVO.init))
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

// MARK: - Mock

extension HomeFeedVO {

    // TestStore·Preview용. 실제 데이터는 HomeClient.fetchHomeFeed로 대체된다.
    public static let mock = HomeFeedVO(
        hasUnreadNotification: true,
        personalized: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(2))),
        recentViewed: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.suffix(2))),
        popular: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(2))),
        deadline: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.dropFirst(2).prefix(2))),
        newest: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.dropFirst(4).prefix(2)))
    )
}
