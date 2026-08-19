// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct RecentSearchResponseDTO: Decodable {
    public let autoSaveEnabled: Bool
    public let keywords: [KeywordDTO]
    public let nextCursor: String
    public let hasNext: Bool
}

public struct KeywordDTO: Decodable {
    public let keywordId: Int
    public let keyword: String
}
