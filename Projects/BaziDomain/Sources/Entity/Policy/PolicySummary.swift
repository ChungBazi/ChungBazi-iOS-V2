// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct PolicySummary: Identifiable, Equatable, Sendable {
    public let id: Int
    public let category: PolicyCategory?
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let viewCount: Int
    public let liked: Bool
    public let registeredDate: String?

    public init(
        id: Int,
        category: PolicyCategory?,
        categoryName: String,
        dDay: String,
        title: String,
        viewCount: Int,
        liked: Bool,
        registeredDate: String? = nil
    ) {
        self.id = id
        self.category = category
        self.categoryName = categoryName
        self.dDay = dDay
        self.title = title
        self.viewCount = viewCount
        self.liked = liked
        self.registeredDate = registeredDate
    }

    /// 찜 낙관적 갱신: id가 일치할 때만 liked를 바꾼 새 값을 반환한다.
    public func updatingLiked(policyId: Int, liked: Bool) -> PolicySummary {
        guard id == policyId else { return self }
        return PolicySummary(
            id: id,
            category: category,
            categoryName: categoryName,
            dDay: dDay,
            title: title,
            viewCount: viewCount,
            liked: liked,
            registeredDate: registeredDate
        )
    }
}
