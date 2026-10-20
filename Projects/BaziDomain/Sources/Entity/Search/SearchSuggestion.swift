// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 검색어 입력 중 자동완성 한 줄(도메인 엔티티). `type`은 서버 원문(히스토리/일반 구분 등).
public struct SearchSuggestion: Equatable, Sendable {
    public let keyword: String
    public let type: String

    public init(keyword: String, type: String) {
        self.keyword = keyword
        self.type = type
    }
}
