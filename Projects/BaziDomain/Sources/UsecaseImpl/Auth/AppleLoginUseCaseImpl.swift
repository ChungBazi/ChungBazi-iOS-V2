// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct AppleLoginUseCaseImpl: AppleLoginUseCase {

    private let authRepository: AuthRepository
    private let pushTokenRepository: PushTokenRepository
    private let sessionStateRepository: SessionStateRepository

    public init(
        authRepository: AuthRepository,
        pushTokenRepository: PushTokenRepository,
        sessionStateRepository: SessionStateRepository
    ) {
        self.authRepository = authRepository
        self.pushTokenRepository = pushTokenRepository
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute(idToken: String, name: String?) async throws -> AccountStatus {
        let fcmToken = await pushTokenRepository.currentToken() ?? ""
        let result = try await authRepository.appleLogin(idToken: idToken, name: name ?? "", fcmToken: fcmToken)
        sessionStateRepository.setHasSetNickname(result.hasNickname)
        sessionStateRepository.setHasCompletedOnboarding(result.hasCompletedOnboarding)
        return result
    }
}
