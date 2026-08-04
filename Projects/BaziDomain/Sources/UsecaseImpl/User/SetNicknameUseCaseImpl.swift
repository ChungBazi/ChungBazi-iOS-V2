// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SetNicknameUseCaseImpl: SetNicknameUseCase {

    private let userRepository: UserRepository
    private let sessionStateRepository: SessionStateRepository

    public init(userRepository: UserRepository, sessionStateRepository: SessionStateRepository) {
        self.userRepository = userRepository
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute(name: String) async throws {
        try await userRepository.updateName(name)
        sessionStateRepository.setHasSetNickname(true)
    }
}
