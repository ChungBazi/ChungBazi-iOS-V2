// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

public struct KakaoLoginUseCaseImpl: KakaoLoginUseCase {

    private let kakaoLoginService: KakaoLoginService
    private let authRepository: AuthRepository
    private let pushTokenRepository: PushTokenRepository
    private let tokenStorage: TokenStorage
    private let sessionStateRepository: SessionStateRepository

    public init(
        kakaoLoginService: KakaoLoginService,
        authRepository: AuthRepository,
        pushTokenRepository: PushTokenRepository,
        tokenStorage: TokenStorage,
        sessionStateRepository: SessionStateRepository
    ) {
        self.kakaoLoginService = kakaoLoginService
        self.authRepository = authRepository
        self.pushTokenRepository = pushTokenRepository
        self.tokenStorage = tokenStorage
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() async throws -> AuthSessionEntity {
        let accessToken = try await kakaoLoginService.login()
        let fcmToken = await pushTokenRepository.currentToken() ?? ""
        let result = try await authRepository.kakaoLogin(accessToken: accessToken, fcmToken: fcmToken)
        tokenStorage.saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        sessionStateRepository.setHasSetNickname(result.hasNickname)
        sessionStateRepository.setHasCompletedOnboarding(result.hasCompletedOnboarding)
        return result
    }
}
