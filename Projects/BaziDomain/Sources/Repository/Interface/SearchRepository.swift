// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 검색·자동완성 및 최근 검색어 통신을 담당한다.
public protocol SearchRepository: Sendable {
    func search(keyword: String, category: PolicyCategory?, sort: String?, cursor: String?, size: Int) async throws -> PolicyPage
    func suggestions(keyword: String) async throws -> [SearchSuggestion]
    func recentSearches(cursor: String?, size: Int) async throws -> RecentSearchResult
    func deleteRecentSearch(keywordId: Int) async throws
    func deleteAllRecentSearches() async throws
    func updateAutoSave(enabled: Bool) async throws
}
