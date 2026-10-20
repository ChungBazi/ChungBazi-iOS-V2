// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 전체보기: 찜한 정책 목록을 조회한다(분야 필터 + 정렬 + 페이지네이션).
public protocol FetchMyPoliciesUseCase: Sendable {
    func execute(category: PolicyCategory?, sort: String, cursor: String?, size: Int) async throws -> PolicyPage
}
