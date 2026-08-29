// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension PolicyMemoResponseDTO {
    func toDomain() -> PolicyMemo {
        PolicyMemo(
            policyId: policyId,
            category: PolicyCategory(rawValue: category),
            categoryName: categoryName,
            dDay: dDay,
            title: title,
            memo: memo
        )
    }
}
