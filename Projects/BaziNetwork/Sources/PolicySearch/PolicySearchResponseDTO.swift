// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SearchSuggestionResponseDTO: Decodable {
    public let suggestions: [SearchSuggestionDTO]
    
    init(suggestions: [SearchSuggestionDTO]) {
        self.suggestions = suggestions
    }
}

public struct SearchSuggestionDTO: Decodable {
    public let type: String
    public let keyword: String
    
    init(type: String, keyword: String) {
        self.type = type
        self.keyword = keyword
    }
}
