// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 마감이 다가오는 찜한 정책 Response DTO
public struct MyPolicyDeadlineResponseDTO: Decodable, Sendable {
    public let policies: [PolicyItemDTO]
}

/// 캘린더 조회 Response DTO
public struct CalendarResponseDTO: Decodable, Sendable {
    public let targetMonth: String
    public let deadlineDates: [String]
}

/// 정책 메모 조회 Response DTO
public struct PolicyMemoResponseDTO: Decodable, Sendable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let memo: String
}
