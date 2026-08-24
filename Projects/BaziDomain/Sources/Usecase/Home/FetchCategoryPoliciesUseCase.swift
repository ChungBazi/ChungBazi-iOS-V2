// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 분야별 정책 목록을 조회한다(페이지네이션).
public protocol FetchCategoryPoliciesUseCase: Sendable {
    func execute(category: PolicyCategory, sort: String, cursor: String?, size: Int) async throws -> PolicyPage
}
