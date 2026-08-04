// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버와의 인증(로그인) 통신을 담당한다.
public protocol AuthRepository: Sendable {
    func kakaoLogin(accessToken: String, fcmToken: String) async throws -> AuthSessionEntity
    func appleLogin(idToken: String, name: String, fcmToken: String) async throws -> AuthSessionEntity
}
