// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 검색어 입력 중 보여주는 자동완성 한 줄(Presentation VO).
/// `isFromHistory`가 true면 최근 검색어 기반이라 히스토리 아이콘을 보여준다.
public struct SearchSuggestionVO: Equatable, Identifiable, Sendable {
    public var id: String { keyword }
    public let keyword: String
    public let isFromHistory: Bool

    public init(keyword: String, isFromHistory: Bool = false) {
        self.keyword = keyword
        self.isFromHistory = isFromHistory
    }

    public init(_ entity: SearchSuggestion) {
        self.init(
            keyword: entity.keyword,
            // 서버 type: RECENT_KEYWORD(최근 검색어) → 히스토리, POLICY_KEYWORD(정책 후보) → 일반.
            isFromHistory: entity.type == "RECENT_KEYWORD"
        )
    }
}

// MARK: - Mock

extension SearchSuggestionVO {

    public static let mockList: [SearchSuggestionVO] = [
        SearchSuggestionVO(keyword: "청년 일자리 지원금", isFromHistory: true),
        SearchSuggestionVO(keyword: "청년 일자리 도약 장려금"),
        SearchSuggestionVO(keyword: "청년 일자리 매칭 프로그램"),
    ]
}
