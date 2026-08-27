// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SaveUserNameUseCaseImpl: SaveUserNameUseCase {

    private let sessionStateRepository: SessionStateRepository

    public init(sessionStateRepository: SessionStateRepository) {
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute(name: String) {
        sessionStateRepository.setUserName(name)
    }
}
