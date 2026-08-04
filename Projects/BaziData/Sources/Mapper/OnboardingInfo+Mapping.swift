// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension OnboardingInfo {
    func toRequestDTO() -> OnboardingRequestDTO {
        OnboardingRequestDTO(
            birth: birth,
            sidoCode: sidoCode,
            sigunguCode: sigunguCode,
            educationCode: educationCode.rawValue,
            employmentCode: employmentCode.rawValue,
            incomeLevel: incomeLevel.rawValue,
            interestCategories: interestCategories.map(\.rawValue)
        )
    }
}
