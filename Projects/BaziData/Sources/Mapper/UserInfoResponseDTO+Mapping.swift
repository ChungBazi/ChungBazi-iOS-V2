// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension UserInfoResponseDTO {
    func toEntity() -> UserProfile {
        UserProfile(
            nickname: name,
            email: email,
            socialType: SocialType(rawValue: socialType)
        )
    }
}
