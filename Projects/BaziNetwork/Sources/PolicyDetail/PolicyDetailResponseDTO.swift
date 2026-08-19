// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세 조회 Response DTO
public struct PolicyDetailResponseDTO: Decodable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let viewCount: Int
    public let liked: Bool
    public let eligibilityDescription: String
    public let applyPeriod: String
    public let supportContent: String
    public let applicationMethod: String
    public let submittedDocument: String
    public let screeningMethod: String
    public let referenceUrls: [String]
    public let policies: [PolicyItemDTO]
    public let popularPolicies: [PolicyItemDTO]
}

/// 정책 카드뉴스 조회 Response DTO
public struct PolicyCardResponseDTO: Decodable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let applyPeriod: String
    public let summary: String
    public let supportContent: String
    public let applyUrl: String
    public let liked: Bool
}
