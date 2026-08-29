// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버와의 인증(로그인) 통신을 담당한다. 응답으로 받은 토큰은 이 계층에서 즉시 저장하고, 화면 분기에 필요한 계정 상태만 반환한다.
public protocol AuthRepository: Sendable {
    func kakaoLogin(accessToken: String, fcmToken: String) async throws -> AccountStatus
    func appleLogin(idToken: String, name: String, fcmToken: String) async throws -> AccountStatus
    /// 현재 세션이 서버 기준 유효한지 검증한다. (인증 필요 요청 1회, non-throwing)
    func validateSession() async -> SessionValidity
    /// 서버 로그아웃. 성공해야 로컬 세션을 초기화한다.
    func logout() async throws
}
