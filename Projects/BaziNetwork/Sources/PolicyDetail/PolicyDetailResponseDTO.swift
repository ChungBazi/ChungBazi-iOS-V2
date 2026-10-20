// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세 조회 Response DTO
/// 내용이 없는 항목은 서버가 `null`을 내려주므로 자유 텍스트/추천 목록 필드는 모두 옵셔널로 둔다.
public struct PolicyDetailResponseDTO: Decodable, Sendable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let summary: String?
    public let viewCount: Int
    public let liked: Bool
    public let eligibilityDescription: String?
    public let applyPeriod: String?
    public let supportContent: String?
    public let applyUrl: String?
    public let applicationMethod: String?
    public let submittedDocument: String?
    public let screeningMethod: String?
    public let referenceUrls: [String]?
    public let policies: [PolicyItemDTO]?
    public let popularPolicies: [PolicyItemDTO]?
}

public struct PolicyCardListResponseDTO: Decodable, Sendable {
    public let policies: [PolicyCardResponseDTO]
}

/// 정책 카드뉴스 조회 Response DTO
public struct PolicyCardResponseDTO: Decodable, Sendable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let applyPeriod: String
    public let summary: String
    public let supportContent: String
    /// 신청 링크가 없는 정책은 서버가 null을 내려주므로 옵셔널.
    public let applyUrl: String?
    public let liked: Bool
}
