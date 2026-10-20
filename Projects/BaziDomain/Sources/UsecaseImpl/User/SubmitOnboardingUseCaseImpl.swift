// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SubmitOnboardingUseCaseImpl: SubmitOnboardingUseCase {

    private let userRepository: UserRepository
    private let sessionStateRepository: SessionStateRepository

    public init(userRepository: UserRepository, sessionStateRepository: SessionStateRepository) {
        self.userRepository = userRepository
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute(_ info: OnboardingInfo) async throws -> String {
        let nickname = try await userRepository.submitOnboarding(info)
        sessionStateRepository.setHasCompletedOnboarding(true)
        return nickname
    }
}
