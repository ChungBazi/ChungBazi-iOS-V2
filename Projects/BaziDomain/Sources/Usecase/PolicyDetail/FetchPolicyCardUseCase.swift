// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 맞춤 정책 카드뉴스(플립카드) 목록을 분야별로 조회한다. category 생략 시 전체 관심 분야 기준.
public protocol FetchPolicyCardUseCase: Sendable {
    func execute(category: PolicyCategory?) async throws -> [PolicyCard]
}
