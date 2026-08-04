// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol CheckSessionUseCase: Sendable {
    func execute() -> (hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool)
}
