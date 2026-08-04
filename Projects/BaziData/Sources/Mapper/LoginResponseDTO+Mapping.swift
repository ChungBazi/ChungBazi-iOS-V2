// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension LoginResponseDTO {
    func toDomain() throws -> AuthSessionEntity {
        guard let socialType = SocialType(rawValue: socialType) else {
            throw UseCaseError.unknown("알 수 없는 socialType: \(socialType)")
        }
        return AuthSessionEntity(
            accessToken: accessToken,
            refreshToken: refreshToken,
            email: email,
            socialType: socialType,
            hasNickname: nicknameChanged,
            hasCompletedOnboarding: onboardingCompleted
        )
    }
}
