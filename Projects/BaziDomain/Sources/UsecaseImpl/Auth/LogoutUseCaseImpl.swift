// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct LogoutUseCaseImpl: LogoutUseCase {

    private let authRepository: AuthRepository

    public init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }

    public func execute() async throws {
        try await authRepository.logout()
    }
}
