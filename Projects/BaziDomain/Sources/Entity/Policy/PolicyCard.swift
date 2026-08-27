// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 카드뉴스(맞춤 플립카드) 상세.
public struct PolicyCard: Equatable, Sendable {
    public let id: Int
    public let category: PolicyCategory?
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let applyPeriod: String
    /// 한 줄 소개(카드 앞면 부제).
    public let summary: String
    /// "어떤 지원을 받을 수 있나요?" 지원 내용(카드 뒷면 원문).
    public let supportContent: String
    public let applyUrl: String
    public let liked: Bool

    public init(
        id: Int,
        category: PolicyCategory?,
        categoryName: String,
        dDay: String,
        title: String,
        applyPeriod: String,
        summary: String,
        supportContent: String,
        applyUrl: String,
        liked: Bool
    ) {
        self.id = id
        self.category = category
        self.categoryName = categoryName
        self.dDay = dDay
        self.title = title
        self.applyPeriod = applyPeriod
        self.summary = summary
        self.supportContent = supportContent
        self.applyUrl = applyUrl
        self.liked = liked
    }
}
