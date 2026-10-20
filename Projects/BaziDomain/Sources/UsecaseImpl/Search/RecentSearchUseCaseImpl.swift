// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct RecentSearchUseCaseImpl: RecentSearchUseCase {

    private let searchRepository: SearchRepository

    public init(searchRepository: SearchRepository) {
        self.searchRepository = searchRepository
    }

    public func fetch(cursor: String?, size: Int) async throws -> RecentSearchResult {
        try await searchRepository.recentSearches(cursor: cursor, size: size)
    }

    public func delete(keywordId: Int) async throws {
        try await searchRepository.deleteRecentSearch(keywordId: keywordId)
    }

    public func deleteAll() async throws {
        try await searchRepository.deleteAllRecentSearches()
    }

    public func updateAutoSave(enabled: Bool) async throws {
        try await searchRepository.updateAutoSave(enabled: enabled)
    }
}
