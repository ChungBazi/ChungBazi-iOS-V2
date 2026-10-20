// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 입력 중인 키워드에 대한 검색 자동완성 목록을 조회한다.
public protocol FetchSearchSuggestionsUseCase: Sendable {
    func execute(keyword: String) async throws -> [SearchSuggestion]
}
