// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension PolicyProfileResponseDTO {
    /// 서버 코드값을 도메인 엔티티로 역매핑. (정책 맞춤 조건은 온보딩과 동일 shape라 OnboardingInfo 재사용)
    func toEntity() -> OnboardingInfo {
        OnboardingInfo(
            birth: birth,
            sidoCode: sidoCode,
            sigunguCode: sigunguCode,
            educationCode: EducationCode(rawValue: educationCode) ?? .etcOrNone,
            employmentCode: EmploymentCode(rawValue: employmentCode) ?? .etcOrNone,
            incomeLevel: IncomeLevel(rawValue: incomeLevel) ?? .unknown,
            interestCategories: interestCategories.compactMap { PolicySubCategoryType(rawValue: $0) },
            specialEligibilities: specialEligibilities.compactMap { SpecialEligibility(rawValue: $0) }
        )
    }
}
