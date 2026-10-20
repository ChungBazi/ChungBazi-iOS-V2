// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 마감 관련 찜한 정책 Response DTO(티저 `/deadline`·정책 탭 `/deadline/upcoming`·캘린더 `/deadline/date` 공용).
/// 티저는 totalCount를 내려주지 않을 수 있어 옵셔널로 둔다.
public struct MyPolicyDeadlineResponseDTO: Decodable, Sendable {
    public let totalCount: Int?
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
