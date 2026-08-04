// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 SDK로 로그인해서 카카오 accessToken을 받아오는 역할
public protocol KakaoLoginService: Sendable {
    func login() async throws -> String
}
