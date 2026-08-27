// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 홈 메인 화면의 섹션별 정책 묶음
public struct HomeFeed: Equatable, Sendable {
    public let userName: String
    public let hasUnreadNotification: Bool
    public let personalized: [PolicySummary]
    public let recentViewed: [PolicySummary]
    public let popular: [PolicySummary]
    public let upcomingDeadline: [PolicySummary]
    public let latest: [PolicySummary]

    public init(
        userName: String,
        hasUnreadNotification: Bool,
        personalized: [PolicySummary],
        recentViewed: [PolicySummary],
        popular: [PolicySummary],
        upcomingDeadline: [PolicySummary],
        latest: [PolicySummary]
    ) {
        self.userName = userName
        self.hasUnreadNotification = hasUnreadNotification
        self.personalized = personalized
        self.recentViewed = recentViewed
        self.popular = popular
        self.upcomingDeadline = upcomingDeadline
        self.latest = latest
    }

    /// 찜 낙관적 갱신: 모든 섹션에서 해당 정책의 liked를 갱신한다.
    public func updatingLiked(policyId: Int, liked: Bool) -> HomeFeed {
        func apply(_ list: [PolicySummary]) -> [PolicySummary] {
            list.map { $0.updatingLiked(policyId: policyId, liked: liked) }
        }
        return HomeFeed(
            userName: userName,
            hasUnreadNotification: hasUnreadNotification,
            personalized: apply(personalized),
            recentViewed: apply(recentViewed),
            popular: apply(popular),
            upcomingDeadline: apply(upcomingDeadline),
            latest: apply(latest)
        )
    }
}
