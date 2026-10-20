// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct UpdatePolicyProfileUseCaseImpl: UpdatePolicyProfileUseCase {

    private let userRepository: UserRepository

    public init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    public func execute(_ info: OnboardingInfo) async throws {
        try await userRepository.updatePolicyProfile(info)
    }
}
