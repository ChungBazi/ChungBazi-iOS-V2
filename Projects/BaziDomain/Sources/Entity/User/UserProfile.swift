// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 내 프로필 정보.
public struct UserProfile: Equatable, Sendable {
    public let nickname: String
    public let email: String
    public let socialType: SocialType

    public init(nickname: String, email: String, socialType: SocialType) {
        self.nickname = nickname
        self.email = email
        self.socialType = socialType
    }
}

/// 소셜 로그인 제공자.
public enum SocialType: String, Equatable, Sendable {
    case kakao = "KAKAO"
    case apple = "APPLE"
}
