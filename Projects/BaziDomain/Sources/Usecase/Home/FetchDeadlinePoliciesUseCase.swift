// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 마감 임박 정책 목록을 조회한다(페이지네이션).
public protocol FetchDeadlinePoliciesUseCase: Sendable {
    func execute(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage
}
