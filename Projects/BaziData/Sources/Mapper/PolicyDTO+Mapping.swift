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
            userName: nickname,
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

extension MyPolicyDeadlineResponseDTO {
    /// 마감(2주 내/해당일) 목록은 페이지네이션이 없다. totalCount 미제공 시 목록 길이로 대체한다.
    func toDomain() -> PolicyPage {
        let items = policies.map { $0.toDomain() }
        return PolicyPage(
            policies: items,
            nextCursor: nil,
            hasNext: false,
            totalCount: totalCount ?? items.count
        )
    }
}
