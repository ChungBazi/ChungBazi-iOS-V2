// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct OnboardingInfo: Equatable, Sendable {
    public let birth: String
    public let sidoCode: String
    public let sigunguCode: String
    public let educationCode: EducationCode
    public let employmentCode: EmploymentCode
    public let incomeLevel: IncomeLevel
    public let interestCategories: [PolicySubCategoryType]

    public init(
        birth: String,
        sidoCode: String,
        sigunguCode: String,
        educationCode: EducationCode,
        employmentCode: EmploymentCode,
        incomeLevel: IncomeLevel,
        interestCategories: [PolicySubCategoryType]
    ) {
        self.birth = birth
        self.sidoCode = sidoCode
        self.sigunguCode = sigunguCode
        self.educationCode = educationCode
        self.employmentCode = employmentCode
        self.incomeLevel = incomeLevel
        self.interestCategories = interestCategories
    }
}
