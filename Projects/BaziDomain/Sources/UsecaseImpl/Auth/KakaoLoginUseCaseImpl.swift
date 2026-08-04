// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct KakaoLoginUseCaseImpl: KakaoLoginUseCase {

    private let kakaoLoginService: KakaoLoginService
    private let authRepository: AuthRepository
    private let pushTokenRepository: PushTokenRepository
    private let sessionStateRepository: SessionStateRepository

    public init(
        kakaoLoginService: KakaoLoginService,
        authRepository: AuthRepository,
        pushTokenRepository: PushTokenRepository,
        sessionStateRepository: SessionStateRepository
    ) {
        self.kakaoLoginService = kakaoLoginService
        self.authRepository = authRepository
        self.pushTokenRepository = pushTokenRepository
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() async throws -> AccountStatus {
        let accessToken = try await kakaoLoginService.login()
        let fcmToken = await pushTokenRepository.currentToken() ?? ""
        let result = try await authRepository.kakaoLogin(accessToken: accessToken, fcmToken: fcmToken)
        sessionStateRepository.setHasSetNickname(result.hasNickname)
        sessionStateRepository.setHasCompletedOnboarding(result.hasCompletedOnboarding)
        return result
    }
}
