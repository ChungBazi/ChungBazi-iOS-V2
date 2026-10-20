// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct SearchSuggestionResponseDTO: Decodable, Sendable {
    public let suggestions: [SearchSuggestionDTO]
}

public struct SearchSuggestionDTO: Decodable, Sendable {
    public let type: String
    public let keyword: String
}
