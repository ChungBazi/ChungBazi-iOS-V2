// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 SDK를 통해 로그인하여 accessToken을 받아온다.
public protocol KakaoLoginService: Sendable {
    func login() async throws -> String
}
