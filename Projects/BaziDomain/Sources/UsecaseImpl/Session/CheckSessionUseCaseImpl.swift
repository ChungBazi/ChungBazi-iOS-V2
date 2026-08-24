// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

public struct CheckSessionUseCaseImpl: CheckSessionUseCase {

    private let tokenStorage: TokenStorage
    private let sessionStateRepository: SessionStateRepository
    private let authRepository: AuthRepository

    public init(
        tokenStorage: TokenStorage,
        sessionStateRepository: SessionStateRepository,
        authRepository: AuthRepository
    ) {
        self.tokenStorage = tokenStorage
        self.sessionStateRepository = sessionStateRepository
        self.authRepository = authRepository
    }

    public func execute() async -> (hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool) {
        (
            hasValidToken: await resolveTokenValidity(),
            hasNickname: sessionStateRepository.hasSetNickname,
            hasCompletedOnboarding: sessionStateRepository.hasCompletedOnboarding
        )
    }

    /// 토큰 유효성은 서버로 판정. 재설치/신규는 마커로 가드, 판정 불가 시 로컬 폴백.
    private func resolveTokenValidity() async -> Bool {
        // 재설치/신규/로그아웃 가드: 마커나 토큰이 없으면 로그인 유도
        guard tokenStorage.hasSessionMarker, tokenStorage.refreshToken != nil else {
            return false
        }
        switch await authRepository.validateSession() {
        case .valid:
            return true
        case .invalid:
            // 확정 만료 → 로컬 세션 초기화
            tokenStorage.clearTokens()
            sessionStateRepository.reset()
            return false
        case .indeterminate:
            // 오프라인/타임아웃/서버오류 → 낙관적 유지 (가드에서 마커 확인됨 = 로그인 이력 존재).
            // 온라인 복귀 시 서버 검증/.forceLogout이 교정한다.
            return true
        }
    }
}
