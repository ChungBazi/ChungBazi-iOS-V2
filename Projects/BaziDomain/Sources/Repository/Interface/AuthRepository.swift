// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol AuthRepository: Sendable {
    func kakaoLogin(accessToken: String, fcmToken: String) async throws -> AuthSessionEntity
    func appleLogin(idToken: String, name: String, fcmToken: String) async throws -> AuthSessionEntity
}
