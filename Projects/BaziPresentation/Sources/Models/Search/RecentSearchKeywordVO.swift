// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 최근 검색어 한 줄(Presentation VO).
public struct RecentSearchKeywordVO: Equatable, Identifiable, Sendable {
    public let id: Int
    public let keyword: String

    public init(id: Int, keyword: String) {
        self.id = id
        self.keyword = keyword
    }

    public init(_ entity: RecentSearchKeyword) {
        self.init(id: entity.id, keyword: entity.keyword)
    }
}

/// 최근 검색어 조회 결과(Presentation VO). 자동저장 여부와 목록을 함께 담는다.
/// (최근 검색어 리스트는 무한 스크롤을 쓰지 않아 커서는 담지 않는다.)
public struct RecentSearchResultVO: Equatable, Sendable {
    public var keywords: IdentifiedArrayOf<RecentSearchKeywordVO>
    public var autoSaveEnabled: Bool

    public init(keywords: IdentifiedArrayOf<RecentSearchKeywordVO>, autoSaveEnabled: Bool) {
        self.keywords = keywords
        self.autoSaveEnabled = autoSaveEnabled
    }

    public init(_ entity: RecentSearchResult) {
        self.init(
            keywords: IdentifiedArray(deduplicating: entity.keywords.map(RecentSearchKeywordVO.init)),
            autoSaveEnabled: entity.autoSaveEnabled
        )
    }
}

// MARK: - Mock

extension RecentSearchResultVO {

    public static let mock = RecentSearchResultVO(
        keywords: IdentifiedArray(uniqueElements: [
            RecentSearchKeywordVO(id: 1, keyword: "청년 일자리 지원금"),
            RecentSearchKeywordVO(id: 2, keyword: "전세자금 대출"),
            RecentSearchKeywordVO(id: 3, keyword: "청년 월세"),
        ]),
        autoSaveEnabled: true
    )
}
