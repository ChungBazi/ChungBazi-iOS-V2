// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct ReissueResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String
}

public struct LoginResponseDTO: Decodable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let email: String
    public let socialType: String
    public let onboardingCompleted: Bool
    public let nicknameChanged: Bool
}
