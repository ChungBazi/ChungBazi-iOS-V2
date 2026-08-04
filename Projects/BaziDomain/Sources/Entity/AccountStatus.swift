// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct AccountStatus: Equatable, Sendable {
    public let hasNickname: Bool
    public let hasCompletedOnboarding: Bool

    public init(hasNickname: Bool, hasCompletedOnboarding: Bool) {
        self.hasNickname = hasNickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
