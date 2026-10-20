// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

public struct ResetSessionUseCaseImpl: ResetSessionUseCase {

    private let tokenStorage: TokenStorage
    private let sessionStateRepository: SessionStateRepository

    public init(tokenStorage: TokenStorage, sessionStateRepository: SessionStateRepository) {
        self.tokenStorage = tokenStorage
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() {
        tokenStorage.clearTokens()
        sessionStateRepository.reset()
    }
}
