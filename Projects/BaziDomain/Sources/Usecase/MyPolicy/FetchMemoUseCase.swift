// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 메모를 조회한다.
public protocol FetchMemoUseCase: Sendable {
    func execute(policyId: Int) async throws -> PolicyMemo
}
