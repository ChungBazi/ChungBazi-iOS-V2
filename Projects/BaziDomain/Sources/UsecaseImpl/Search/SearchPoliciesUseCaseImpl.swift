// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SearchPoliciesUseCaseImpl: SearchPoliciesUseCase {

    private let searchRepository: SearchRepository

    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    public func execute(keyword: String, category: PolicyCategory?, sort: String?, cursor: String?, size: Int) async throws -> PolicyPage {
        try await searchRepository.search(keyword: keyword, category: category, sort: sort, cursor: cursor, size: size)
    }
}
