// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension PolicyItemDTO {
    func toDomain() -> PolicySummary {
        PolicySummary(
            id: policyId,
            category: PolicyCategory(rawValue: category),
            categoryName: categoryName,
            dDay: dDay,
            title: title,
            viewCount: viewCount,
            liked: liked
        )
    }
}

extension HomePolicySectionResponseDTO {
    func toDomain() -> HomeFeed {
        HomeFeed(
            hasUnreadNotification: hasUnreadNotification,
            personalized: personalizedPolicies.map { $0.toDomain() },
            recentViewed: recentViewedPolicies.map { $0.toDomain() },
            popular: popularPolicies.map { $0.toDomain() },
            upcomingDeadline: upcomingDeadlinePolicies.map { $0.toDomain() },
            latest: latestPolicies.map { $0.toDomain() }
        )
    }
}

extension PolicyListResponseDTO {
    func toDomain() -> PolicyPage {
        PolicyPage(
            policies: policies.map { $0.toDomain() },
            nextCursor: hasNext ? nextCursor : nil,
            hasNext: hasNext,
            totalCount: totalCount
        )
    }
}
