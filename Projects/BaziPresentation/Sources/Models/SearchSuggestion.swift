// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 검색어 입력 중 보여주는 자동완성 한 줄. `SearchSuggestionDTO`와 필드를 맞췄다.
/// `isFromHistory`가 true면 최근 검색어와 일치해 히스토리 아이콘을 보여준다.
public struct SearchSuggestion: Equatable, Identifiable, Sendable {
    public var id: String { keyword }
    public let keyword: String
    public let isFromHistory: Bool

    public init(keyword: String, isFromHistory: Bool = false) {
        self.keyword = keyword
        self.isFromHistory = isFromHistory
    }
}

// MARK: - Mock

extension SearchSuggestion {

    // TODO: BaziDomain의 검색 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    private static let corpus = [
        "청년 일자리 도약 장려금",
        "청년 일자리 지원금",
        "청년 일자리 매칭 프로그램",
        "청년 일자리 창출 지원",
        "청년 일자리 인턴십",
    ]

    public static func suggestions(for query: String, recentKeywords: [String]) -> [SearchSuggestion] {
        guard !query.isEmpty else { return [] }
        return corpus
            .filter { $0.contains(query) }
            .map { SearchSuggestion(keyword: $0, isFromHistory: recentKeywords.contains($0)) }
    }
}
