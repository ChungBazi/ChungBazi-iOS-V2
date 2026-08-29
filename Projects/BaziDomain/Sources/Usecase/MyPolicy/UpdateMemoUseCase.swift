// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 메모를 작성/수정한다.
public protocol UpdateMemoUseCase: Sendable {
    func execute(policyId: Int, memo: String) async throws
}
