// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension SearchSuggestionResponseDTO {
    func toDomain() -> [SearchSuggestion] {
        suggestions.map { SearchSuggestion(keyword: $0.keyword, type: $0.type) }
    }
}

extension RecentSearchResponseDTO {
    func toDomain() -> RecentSearchResult {
        RecentSearchResult(
            keywords: keywords.map { RecentSearchKeyword(id: $0.keywordId, keyword: $0.keyword) },
            autoSaveEnabled: autoSaveEnabled,
            nextCursor: nextCursor,
            hasNext: hasNext
        )
    }
}
