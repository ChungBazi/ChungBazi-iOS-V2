// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SearchSuggestionResponseDTO: Decodable {
    public let suggestions: [SearchSuggestionDTO]
}

public struct SearchSuggestionDTO: Decodable {
    public let type: String
    public let keyword: String
}
