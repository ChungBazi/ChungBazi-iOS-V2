// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchPersonalizedPoliciesUseCaseImpl: FetchPersonalizedPoliciesUseCase {

    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func execute(category: PolicyCategory) async throws -> [PolicySummary] {
        try await homeRepository.fetchPersonalizedPolicies(category: category)
    }
}
