// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

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
