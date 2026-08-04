// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum SocialType: String, Equatable, Sendable {
    case kakao = "KAKAO"
    case apple = "APPLE"
}

public struct AuthSessionEntity: Equatable, Sendable {
    public let accessToken: String
    public let refreshToken: String
    public let email: String
    public let socialType: SocialType
    public let hasNickname: Bool
    public let hasCompletedOnboarding: Bool

    public init(
        accessToken: String,
        refreshToken: String,
        email: String,
        socialType: SocialType,
        hasNickname: Bool,
        hasCompletedOnboarding: Bool
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.email = email
        self.socialType = socialType
        self.hasNickname = hasNickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
