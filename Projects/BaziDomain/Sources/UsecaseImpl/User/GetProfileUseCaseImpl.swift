// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct GetProfileUseCaseImpl: GetProfileUseCase {

    private let userRepository: UserRepository
    private let sessionStateRepository: SessionStateRepository

    public init(userRepository: UserRepository, sessionStateRepository: SessionStateRepository) {
        self.userRepository = userRepository
        self.sessionStateRepository = sessionStateRepository
    }

    public func execute() async throws -> UserProfile {
        let profile = try await userRepository.getProfile()
        // /me 응답의 소셜 제공자를 세션에 동기화한다. (탈퇴 시 카카오 판별에 사용)
        sessionStateRepository.setSocialType(profile.socialType)
        return profile
    }
}
