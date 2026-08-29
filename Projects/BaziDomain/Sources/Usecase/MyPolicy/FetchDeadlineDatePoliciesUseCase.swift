// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 특정 마감일의 정책 목록을 조회한다(정렬 + 페이지네이션).
public protocol FetchDeadlineDatePoliciesUseCase: Sendable {
    func execute(targetDate: String, sort: String, cursor: String?, size: Int) async throws -> PolicyPage
}
