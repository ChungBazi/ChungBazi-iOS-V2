// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchLatestPoliciesUseCaseImpl: FetchLatestPoliciesUseCase {

    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func execute(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage {
        try await homeRepository.fetchLatestPolicies(category: category, cursor: cursor, size: size)
    }
}
