// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol SubmitOnboardingUseCase: Sendable {
    func execute(_ info: OnboardingInfoEntity) async throws
}
