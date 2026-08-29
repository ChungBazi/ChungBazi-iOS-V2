// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 내 프로필(닉네임·이메일·소셜타입)을 조회한다.
public protocol GetProfileUseCase: Sendable {
    func execute() async throws -> UserProfile
}
