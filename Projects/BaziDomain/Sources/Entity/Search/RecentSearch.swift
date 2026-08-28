// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 최근 검색어 한 줄(도메인 엔티티).
public struct RecentSearchKeyword: Equatable, Sendable {
    public let id: Int
    public let keyword: String

    public init(id: Int, keyword: String) {
        self.id = id
        self.keyword = keyword
    }
}

/// 최근 검색어 조회 결과. 자동저장 여부와 커서 페이지네이션 정보를 함께 담는다.
public struct RecentSearchResult: Equatable, Sendable {
    public let keywords: [RecentSearchKeyword]
    public let autoSaveEnabled: Bool
    public let nextCursor: String?
    public let hasNext: Bool

    public init(keywords: [RecentSearchKeyword], autoSaveEnabled: Bool, nextCursor: String?, hasNext: Bool) {
        self.keywords = keywords
        self.autoSaveEnabled = autoSaveEnabled
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}
