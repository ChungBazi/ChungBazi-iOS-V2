// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

public struct AppleLoginUseCaseImpl: AppleLoginUseCase {

    private let authRepository: AuthRepository
    private let pushTokenRepository: PushTokenRepository
    private let tokenStorage: TokenStorage
    private let sessionStateRepository: SessionStateRepository

    public init(
        authRepository: AuthRepository,
        pushTokenRepository: PushTokenRepository,
        tokenStorage: TokenStorage,
        sessionStateRepository: SessionStateRepository
    ) {
        self.authRepository = authRepository
        self.pushTokenRepository = pushTokenRepository
        self.tokenStorage = tokenStorage
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute(idToken: String, name: String?) async throws -> AuthSessionEntity {
        let fcmToken = await pushTokenRepository.currentToken() ?? ""
        let result = try await authRepository.appleLogin(idToken: idToken, name: name ?? "", fcmToken: fcmToken)
        tokenStorage.saveTokens(accessToken: result.accessToken, refreshToken: result.refreshToken)
        sessionStateRepository.setHasSetNickname(result.hasNickname)
        sessionStateRepository.setHasCompletedOnboarding(result.hasCompletedOnboarding)
        return result
    }
}
