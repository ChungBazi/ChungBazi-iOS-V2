// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct SearchRepositoryImpl: SearchRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func search(keyword: String, category: PolicyCategory?, sort: String?, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            PolicySearchAPI.search(keyword: keyword, category: category?.rawValue, sort: sort, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func suggestions(keyword: String) async throws -> [SearchSuggestion] {
        let dto: SearchSuggestionResponseDTO = try await networkProvider.request(
            PolicySearchAPI.getSearchSuggestions(keyword: keyword)
        )
        return dto.toDomain()
    }

    public func recentSearches(cursor: String?, size: Int) async throws -> RecentSearchResult {
        let dto: RecentSearchResponseDTO = try await networkProvider.request(
            RecentSearchAPI.getRecentSearches(cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func deleteRecentSearch(keywordId: Int) async throws {
        try await networkProvider.requestStatusCode(RecentSearchAPI.deleteRecentSearch(keywordId: keywordId))
    }

    public func deleteAllRecentSearches() async throws {
        try await networkProvider.requestStatusCode(RecentSearchAPI.deleteAllRecentSearches)
    }

    public func updateAutoSave(enabled: Bool) async throws {
        try await networkProvider.requestStatusCode(
            RecentSearchAPI.updateAutoSave(body: UpdateAutoSaveRequestDTO(enabled: enabled))
        )
    }
}
