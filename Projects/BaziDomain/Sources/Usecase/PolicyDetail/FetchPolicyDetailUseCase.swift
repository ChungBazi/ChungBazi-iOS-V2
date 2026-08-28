// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세(추천 정책 포함)를 조회한다.
public protocol FetchPolicyDetailUseCase: Sendable {
    func execute(policyId: Int) async throws -> PolicyDetail
}
