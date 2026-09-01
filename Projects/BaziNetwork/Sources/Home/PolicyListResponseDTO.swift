// Copyright © 2026 ChungBazi. All rights reserved

import Foundation

public struct HomePolicySectionResponseDTO: Decodable, Sendable {
    public let nickname: String
    public let hasUnreadNotification: Bool
    public let personalizedPolicies: [PolicyItemDTO]
    public let recentViewedPolicies: [PolicyItemDTO]
    public let popularPolicies: [PolicyItemDTO]
    public let upcomingDeadlinePolicies: [PolicyItemDTO]
    public let latestPolicies: [PolicyItemDTO]
}

/// 분야별 맞춤 정책 목록 Response DTO
public struct PersonalizedPolicyResponseDTO: Decodable, Sendable {
    public let policies: [PolicyItemDTO]
}

/// Home과 Search 결과 정책 리스트 Response를 담는 DTO
public struct PolicyListResponseDTO: Decodable, Sendable {
    public let totalCount: Int
    public let policies: [PolicyItemDTO]
    /// 마지막 페이지면 서버가 null을 내려주므로 옵셔널.
    public let nextCursor: String?
    public let hasNext: Bool
}

public struct PolicyItemDTO: Decodable, Sendable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let registeredDate: String
    public let viewCount: Int
    public let liked: Bool
}
