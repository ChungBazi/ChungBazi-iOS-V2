// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import BaziDomain

/// `UserProfile` 엔티티를 화면 표시용으로 감싼 VO. (로그인된 소셜 계정 화면 등)
public struct UserProfileVO: Equatable, Sendable {

    public let nickname: String
    public let email: String
    public let socialType: SocialType

    public init(_ entity: UserProfile) {
        self.nickname = entity.nickname
        self.email = entity.email
        self.socialType = entity.socialType
    }

    /// 소셜 제공자 표시명.
    public var socialDisplayName: String {
        switch socialType {
        case .kakao: return "카카오톡"
        case .apple: return "Apple"
        }
    }

    /// 소셜 제공자 아이콘. (kakao=디자인 에셋, apple=SF Symbol)
    public var socialIcon: Image {
        switch socialType {
        case .kakao: return Image.bazi(.kakaoIcon)
        case .apple: return Image(systemName: "applelogo")
        }
    }
}
