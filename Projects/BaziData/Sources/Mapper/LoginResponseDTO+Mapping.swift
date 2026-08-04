// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension LoginResponseDTO {
    func toDomain() -> AccountStatus {
        AccountStatus(hasNickname: nicknameChanged, hasCompletedOnboarding: onboardingCompleted)
    }
}
