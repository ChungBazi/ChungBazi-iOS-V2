// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 온보딩, 정책 추천 기준 수정 Request DTO
public struct OnboardingRequestDTO: Encodable {
    public let birth: String
    public let sidoCode: String
    public let sigunguCode: String
    public let educationCode: String
    public let employmentCode: String
    public let incomeLevel: String
    public let interestCategories: [String]

    public init(birth: String, sidoCode: String, sigunguCode: String, educationCode: String, employmentCode: String, incomeLevel: String, interestCategories: [String]) {
        self.birth = birth
        self.sidoCode = sidoCode
        self.sigunguCode = sigunguCode
        self.educationCode = educationCode
        self.employmentCode = employmentCode
        self.incomeLevel = incomeLevel
        self.interestCategories = interestCategories
    }
}

public struct NameRequestDTO: Encodable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}
