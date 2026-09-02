// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct AppleLoginUseCaseImpl: AppleLoginUseCase {

    private let appleAuthService: AppleAuthService
    private let authRepository: AuthRepository
    private let pushTokenRepository: PushTokenRepository
    private let sessionStateRepository: SessionStateRepository

    public init(
        appleAuthService: AppleAuthService,
        authRepository: AuthRepository,
        pushTokenRepository: PushTokenRepository,
        sessionStateRepository: SessionStateRepository
    ) {
        self.appleAuthService = appleAuthService
        self.authRepository = authRepository
        self.pushTokenRepository = pushTokenRepository
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() async throws -> AccountStatus {
        let credential = try await appleAuthService.login()
        let fcmToken = await pushTokenRepository.currentToken() ?? ""
        let result = try await authRepository.appleLogin(idToken: credential.idToken, name: credential.name ?? "", fcmToken: fcmToken)
        sessionStateRepository.setHasSetNickname(result.hasNickname)
        sessionStateRepository.setHasCompletedOnboarding(result.hasCompletedOnboarding)
        sessionStateRepository.setSocialType(.apple)
        return result
    }
}
