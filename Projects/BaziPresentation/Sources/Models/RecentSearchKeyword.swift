// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 최근 검색어 한 줄. `KeywordDTO`와 필드를 맞췄다.
public struct RecentSearchKeyword: Equatable, Identifiable, Sendable {
    public let id: Int
    public let keyword: String

    public init(id: Int, keyword: String) {
        self.id = id
        self.keyword = keyword
    }
}

// MARK: - Mock

extension RecentSearchKeyword {

    // TODO: BaziDomain의 검색 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mockList: [RecentSearchKeyword] = [
        RecentSearchKeyword(id: 1, keyword: "청년 일자리 지원금"),
        RecentSearchKeyword(id: 2, keyword: "전세자금 대출"),
        RecentSearchKeyword(id: 3, keyword: "청년 월세"),
        RecentSearchKeyword(id: 4, keyword: "취업 장려금"),
        RecentSearchKeyword(id: 5, keyword: "교육비 지원"),
    ]
}
