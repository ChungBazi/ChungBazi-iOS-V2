// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol KakaoLoginUseCase: Sendable {
    func execute() async throws -> AuthSessionEntity
}
