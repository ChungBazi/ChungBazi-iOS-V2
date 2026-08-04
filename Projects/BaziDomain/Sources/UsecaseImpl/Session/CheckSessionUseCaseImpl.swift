// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

public struct CheckSessionUseCaseImpl: CheckSessionUseCase {

    private let tokenStorage: TokenStorage
    private let sessionStateRepository: SessionStateRepository

    public init(tokenStorage: TokenStorage, sessionStateRepository: SessionStateRepository) {
        self.tokenStorage = tokenStorage
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() -> (hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool) {
        (
            hasValidToken: tokenStorage.accessToken != nil,
            hasNickname: sessionStateRepository.hasSetNickname,
            hasCompletedOnboarding: sessionStateRepository.hasCompletedOnboarding
        )
    }
}
