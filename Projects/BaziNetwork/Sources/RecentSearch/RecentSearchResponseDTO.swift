// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct RecentSearchResponseDTO: Decodable, Sendable {
    public let autoSaveEnabled: Bool
    public let keywords: [KeywordDTO]
    // 마지막 페이지에서는 서버가 null을 줄 수 있어 옵셔널.
    public let nextCursor: String?
    public let hasNext: Bool
}

public struct KeywordDTO: Decodable, Sendable {
    public let keywordId: Int
    public let keyword: String
}
