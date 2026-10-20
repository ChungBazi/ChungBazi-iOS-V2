// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct UserNameUseCaseImpl: UserNameUseCase {

    private let sessionStateRepository: SessionStateRepository

    public init(sessionStateRepository: SessionStateRepository) {
        self.sessionStateRepository = sessionStateRepository
    }

    public func get() -> String? {
        sessionStateRepository.userName
    }

    public func save(_ name: String) {
        sessionStateRepository.setUserName(name)
    }
}
