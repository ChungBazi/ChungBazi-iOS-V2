// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchCategoryPoliciesUseCaseImpl: FetchCategoryPoliciesUseCase {

    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func execute(category: PolicyCategory, sort: String, cursor: String?, size: Int) async throws -> PolicyPage {
        try await homeRepository.fetchCategoryPolicies(category: category, sort: sort, cursor: cursor, size: size)
    }
}
