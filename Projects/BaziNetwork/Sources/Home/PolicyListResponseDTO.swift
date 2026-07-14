// Copyright © 2026 ChungBazi. All rights reserved

import Foundation

/// Home과 Search 결과 정책 리스트 Response를 담는 DTO
public struct PolicyListResponseDTO: Decodable {
    public let totalCount: Int
    public let policies: [PolicyItemDTO]
    public let nextCursor: String
    public let hasNext: Bool
    
    init(totalCount: Int, policies: [PolicyItemDTO], nextCursor: String, hasNext: Bool) {
        self.totalCount = totalCount
        self.policies = policies
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}

public struct PolicyItemDTO: Decodable {
    public let policyId: Int
    public let category: String
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let viewCount: Int
    public let liked: Bool
    
    init(policyId: Int, category: String, categoryName: String, dDay: String, title: String, viewCount: Int, liked: Bool) {
        self.policyId = policyId
        self.category = category
        self.categoryName = categoryName
        self.dDay = dDay
        self.title = title
        self.viewCount = viewCount
        self.liked = liked
    }
}
