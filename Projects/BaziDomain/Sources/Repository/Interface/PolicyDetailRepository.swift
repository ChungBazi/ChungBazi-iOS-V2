// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세/카드 및 찜(like) 통신을 담당한다.
public protocol PolicyDetailRepository: Sendable {
    func fetchPolicyCard(policyId: Int) async throws -> PolicyCard
}
