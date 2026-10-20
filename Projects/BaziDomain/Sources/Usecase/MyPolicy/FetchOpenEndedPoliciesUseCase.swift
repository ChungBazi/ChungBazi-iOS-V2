// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 상시모집 정책 목록을 조회한다(정렬 없음, 페이지네이션).
public protocol FetchOpenEndedPoliciesUseCase: Sendable {
    func execute(cursor: String?, size: Int) async throws -> PolicyPage
}
