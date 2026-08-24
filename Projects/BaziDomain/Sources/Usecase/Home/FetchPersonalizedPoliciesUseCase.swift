// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 개인별 맞춤 정책을 조회한다.
public protocol FetchPersonalizedPoliciesUseCase: Sendable {
    func execute(category: PolicyCategory) async throws -> [PolicySummary]
}
