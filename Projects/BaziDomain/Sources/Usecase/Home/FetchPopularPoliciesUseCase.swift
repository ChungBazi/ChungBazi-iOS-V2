// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 인기 정책 목록을 조회한다(페이지네이션).
public protocol FetchPopularPoliciesUseCase: Sendable {
    func execute(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage
}
