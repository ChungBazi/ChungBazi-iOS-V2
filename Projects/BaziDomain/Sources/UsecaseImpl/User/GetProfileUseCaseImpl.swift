// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct GetProfileUseCaseImpl: GetProfileUseCase {

    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> UserProfile {
        try await userRepository.getProfile()
    }
}
