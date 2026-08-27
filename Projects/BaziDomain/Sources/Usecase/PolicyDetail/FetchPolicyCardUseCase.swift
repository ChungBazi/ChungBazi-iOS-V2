// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 카드뉴스(플립카드) 상세를 조회한다.
public protocol FetchPolicyCardUseCase: Sendable {
    func execute(policyId: Int) async throws -> PolicyCard
}
