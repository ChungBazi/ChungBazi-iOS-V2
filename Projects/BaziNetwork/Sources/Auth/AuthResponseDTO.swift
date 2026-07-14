// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct ReissueResponseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
    
    init(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

public struct LoginResponseDTO: Decodable {
    public let accessToken: String
    public let refreshToken: String
    public let email: String
    public let socialType: String
    public let onboardingCompleted: Bool
    
    init(accessToken: String, refreshToken: String, email: String, socialType: String, onboardingCompleted: Bool) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.email = email
        self.socialType = socialType
        self.onboardingCompleted = onboardingCompleted
    }
}
