// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세(도메인 엔티티). 추천 정책(맞춤/인기)도 상세 응답에 함께 담겨 온다.
public struct PolicyDetail: Equatable, Sendable {
    public let id: Int
    public let category: PolicyCategory?
    public let categoryName: String
    public let dDay: String
    public let title: String
    public let summary: String
    public let viewCount: Int
    public let liked: Bool
    public let eligibilityDescription: String
    public let applyPeriod: String
    public let supportContent: String
    public let applicationMethod: String
    public let submittedDocument: String
    public let screeningMethod: String
    public let referenceUrls: [String]
    public let personalized: [PolicySummary]
    public let popular: [PolicySummary]

    public init(
        id: Int,
        category: PolicyCategory?,
        categoryName: String,
        dDay: String,
        title: String,
        summary: String,
        viewCount: Int,
        liked: Bool,
        eligibilityDescription: String,
        applyPeriod: String,
        supportContent: String,
        applicationMethod: String,
        submittedDocument: String,
        screeningMethod: String,
        referenceUrls: [String],
        personalized: [PolicySummary],
        popular: [PolicySummary]
    ) {
        self.id = id
        self.category = category
        self.categoryName = categoryName
        self.dDay = dDay
        self.title = title
        self.summary = summary
        self.viewCount = viewCount
        self.liked = liked
        self.eligibilityDescription = eligibilityDescription
        self.applyPeriod = applyPeriod
        self.supportContent = supportContent
        self.applicationMethod = applicationMethod
        self.submittedDocument = submittedDocument
        self.screeningMethod = screeningMethod
        self.referenceUrls = referenceUrls
        self.personalized = personalized
        self.popular = popular
    }
}
