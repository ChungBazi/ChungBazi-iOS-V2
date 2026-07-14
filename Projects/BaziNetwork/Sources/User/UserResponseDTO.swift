// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct PolicyProfileResponseDTO: Decodable {
    public let birth: String
    public let sidoCode: String
    public let sigunguCode: String
    public let educationCode: String
    public let employmentCode: String
    public let incomeLevel: String
    public let interestCategories: [String]
    
    init(birth: String, sidoCode: String, sigunguCode: String, educationCode: String, employmentCode: String, incomeLevel: String, interestCategories: [String]) {
        self.birth = birth
        self.sidoCode = sidoCode
        self.sigunguCode = sigunguCode
        self.educationCode = educationCode
        self.employmentCode = employmentCode
        self.incomeLevel = incomeLevel
        self.interestCategories = interestCategories
    }
}

public struct UserInfoResponseDTO: Decodable {
    public let name: String
    public let email: String
    public let socialType: String
    
    init(name: String, email: String, socialType: String) {
        self.name = name
        self.email = email
        self.socialType = socialType
    }
}
