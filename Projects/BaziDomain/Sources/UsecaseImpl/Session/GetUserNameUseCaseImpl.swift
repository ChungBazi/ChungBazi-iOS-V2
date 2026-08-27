// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct GetUserNameUseCaseImpl: GetUserNameUseCase {

    private let sessionStateRepository: SessionStateRepository

    public init(sessionStateRepository: SessionStateRepository) {
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() -> String? {
        sessionStateRepository.userName
    }
}
