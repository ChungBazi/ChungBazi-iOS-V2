// Copyright © 2026 ChungBazi. All rights reserved

import Foundation

public struct HomePolicySectionResponseDTO: Decodable {
    public let hasUnreadNotification: Bool
    public let personalizedPolicies: [PolicyItemDTO]
    public let recentViewedPolicies: [PolicyItemDTO]
    public let popularPolicies: [PolicyItemDTO]
    public let upcomingDeadlinePolicies: [PolicyItemDTO]
    public let latestPolicies: [PolicyItemDTO]
}

/// 분야별 맞춤 정책 목록 Response DTO
public struct PersonalizedPolicyResponseDTO: Decodable {
    public let policies: [PolicyItemDTO]
}

/// Home과 Search 결과 정책 리스트 Response를 담는 DTO
public struct PolicyListResponseDTO: Decodable {
    public let totalCount: Int
    public let policies: [PolicyItemDTO]
    public let nextCursor: String
    public let hasNext: Bool
}

public struct PolicyItemDTO: Decodable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let viewCount: Int
    public let liked: Bool
}
