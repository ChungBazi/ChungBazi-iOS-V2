// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchSearchSuggestionsUseCaseImpl: FetchSearchSuggestionsUseCase {

    private let searchRepository: SearchRepository

    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    public func execute(keyword: String) async throws -> [SearchSuggestion] {
        try await searchRepository.suggestions(keyword: keyword)
    }
}
