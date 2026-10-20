// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 최근 검색어 조회/삭제 및 자동저장 설정을 담당한다.
public protocol RecentSearchUseCase: Sendable {
    func fetch(cursor: String?, size: Int) async throws -> RecentSearchResult
    func delete(keywordId: Int) async throws
    func deleteAll() async throws
    func updateAutoSave(enabled: Bool) async throws
}
