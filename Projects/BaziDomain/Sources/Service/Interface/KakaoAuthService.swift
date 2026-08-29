// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 SDK 인증 동작(로그인 · 연결 해제)을 담당한다.
public protocol KakaoAuthService: Sendable {
    /// 카카오 SDK로 로그인하여 accessToken을 받아온다.
    func login() async throws -> String
    /// 앱↔카카오 연결을 해제한다. (탈퇴 시 사용, 카카오 토큰이 없으면 no-op)
    func unlink() async throws
}
