// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct GetPolicyProfileUseCaseImpl: GetPolicyProfileUseCase {

    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute() async throws -> OnboardingInfo {
        try await userRepository.getPolicyProfile()
    }
}
