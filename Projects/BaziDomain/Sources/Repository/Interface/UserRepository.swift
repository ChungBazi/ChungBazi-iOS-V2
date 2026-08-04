// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol UserRepository: Sendable {
    func updateName(_ name: String) async throws
    func submitOnboarding(_ info: OnboardingInfoEntity) async throws
}
