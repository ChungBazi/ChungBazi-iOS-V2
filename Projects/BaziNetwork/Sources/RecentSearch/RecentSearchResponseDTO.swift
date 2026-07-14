// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct RecentSearchResponseDTO: Decodable {
    public let autoSaveEnabled: Bool
    public let keyword: [KeywordDTO]
    public let nextCursor: String
    public let hasNext: Bool
    
    init(autoSaveEnabled: Bool, keyword: [KeywordDTO], nextCursor: String, hasNext: Bool) {
        self.autoSaveEnabled = autoSaveEnabled
        self.keyword = keyword
        self.nextCursor = nextCursor
        self.hasNext = hasNext
    }
}

public struct KeywordDTO: Decodable {
    public let keywordId: Int
    public let keyword: String
    
    init(keywordId: Int, keyword: String) {
        self.keywordId = keywordId
        self.keyword = keyword
    }
}
