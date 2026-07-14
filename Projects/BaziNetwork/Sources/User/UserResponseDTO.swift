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
}

public struct UserInfoResponseDTO: Decodable {
    public let name: String
    public let email: String
    public let socialType: String
}
