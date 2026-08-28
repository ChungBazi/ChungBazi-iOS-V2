// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 검색 플로우 전용 Client. 검색(커서 페이지네이션)·자동완성·최근 검색어를 담당한다.
@DependencyClient
public struct PolicySearchClient: Sendable {
    public var search: @Sendable (_ keyword: String, _ category: PolicyCategoryUI?, _ sort: String?, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
    public var suggestions: @Sendable (_ keyword: String) async throws -> [SearchSuggestionVO]
    public var recentSearches: @Sendable (_ cursor: String?, _ size: Int) async throws -> RecentSearchResultVO
    public var deleteRecentSearch: @Sendable (_ keywordId: Int) async throws -> Void
    public var deleteAllRecentSearches: @Sendable () async throws -> Void
    public var updateAutoSave: @Sendable (_ enabled: Bool) async throws -> Void
}

extension PolicySearchClient: TestDependencyKey {
    public static let testValue = PolicySearchClient()

    public static let previewValue = PolicySearchClient(
        search: { _, _, _, _, _ in
            PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: PolicySummaryVO.mockList),
                nextCursor: nil,
                hasNext: false,
                totalCount: PolicySummaryVO.mockList.count
            )
        },
        suggestions: { _ in SearchSuggestionVO.mockList },
        recentSearches: { _, _ in .mock },
        deleteRecentSearch: { _ in },
        deleteAllRecentSearches: {},
        updateAutoSave: { _ in }
    )
}

extension DependencyValues {
    public var policySearchClient: PolicySearchClient {
        get { self[PolicySearchClient.self] }
        set { self[PolicySearchClient.self] = newValue }
    }
}
