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

public struct UserInfoResponseDTO: Decodable, Sendable {
    public let name: String
    public let email: String
    public let socialType: String
}

/// 온보딩 제출 응답. 서버가 설정된 닉네임을 돌려준다.
public struct OnboardingResponseDTO: Decodable, Sendable {
    public let nickname: String
}
