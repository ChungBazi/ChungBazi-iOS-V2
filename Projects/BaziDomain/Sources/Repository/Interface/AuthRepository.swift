// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버와의 인증(로그인) 통신을 담당한다. 응답으로 받은 토큰은 이 계층에서 즉시 저장하고,
/// 화면 분기에 필요한 계정 상태만 반환한다.
public protocol AuthRepository: Sendable {
    func kakaoLogin(accessToken: String, fcmToken: String) async throws -> AccountStatus
    func appleLogin(idToken: String, name: String, fcmToken: String) async throws -> AccountStatus
}
