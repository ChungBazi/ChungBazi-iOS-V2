// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 홈 메인 화면이 한 번에 그리는 섹션별 정책 묶음(Presentation VO).
/// userName은 세션 상태이므로 여기 담지 않고 SessionClient에서 읽는다.
public struct HomeFeedVO: Equatable, Sendable {
    public var hasUnreadNotification: Bool
    public var personalized: IdentifiedArrayOf<PolicySummary>
    public var recentViewed: IdentifiedArrayOf<PolicySummary>
    public var popular: IdentifiedArrayOf<PolicySummary>
    public var deadline: IdentifiedArrayOf<PolicySummary>
    public var newest: IdentifiedArrayOf<PolicySummary>

    public init(
        hasUnreadNotification: Bool,
        personalized: IdentifiedArrayOf<PolicySummary>,
        recentViewed: IdentifiedArrayOf<PolicySummary>,
        popular: IdentifiedArrayOf<PolicySummary>,
        deadline: IdentifiedArrayOf<PolicySummary>,
        newest: IdentifiedArrayOf<PolicySummary>
    ) {
        self.hasUnreadNotification = hasUnreadNotification
        self.personalized = personalized
        self.recentViewed = recentViewed
        self.popular = popular
        self.deadline = deadline
        self.newest = newest
    }
}

// MARK: - Mock

extension HomeFeedVO {

    // TestStore·Preview용. 실제 데이터는 HomeClient.fetchHomeFeed로 대체된다.
    public static let mock = HomeFeedVO(
        hasUnreadNotification: true,
        personalized: IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2))),
        recentViewed: IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.suffix(2))),
        popular: IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2))),
        deadline: IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.dropFirst(2).prefix(2))),
        newest: IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.dropFirst(4).prefix(2)))
    )
}
