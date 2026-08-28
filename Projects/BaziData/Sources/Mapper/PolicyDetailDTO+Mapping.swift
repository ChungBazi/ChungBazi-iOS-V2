// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension PolicyDetailResponseDTO {
    func toDomain() -> PolicyDetail {
        PolicyDetail(
            id: policyId,
            category: PolicyCategory(rawValue: category),
            categoryName: categoryName,
            dDay: dDay,
            title: title,
            summary: summary ?? "",
            viewCount: viewCount,
            liked: liked,
            eligibilityDescription: eligibilityDescription ?? "",
            applyPeriod: applyPeriod ?? "",
            supportContent: supportContent ?? "",
            applicationMethod: applicationMethod ?? "",
            submittedDocument: submittedDocument ?? "",
            screeningMethod: screeningMethod ?? "",
            referenceUrls: referenceUrls ?? [],
            personalized: (policies ?? []).map { $0.toDomain() },
            popular: (popularPolicies ?? []).map { $0.toDomain() }
        )
    }
}

extension PolicyCardResponseDTO {
    func toDomain() -> PolicyCard {
        PolicyCard(
            id: policyId,
            category: PolicyCategory(rawValue: category),
            categoryName: categoryName,
            dDay: dDay,
            title: title,
            applyPeriod: applyPeriod,
            summary: summary,
            supportContent: supportContent,
            applyUrl: applyUrl,
            liked: liked
        )
    }
}
