// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol AppleLoginUseCase: Sendable {
    func execute(idToken: String, name: String?) async throws -> AuthSessionEntity
}
