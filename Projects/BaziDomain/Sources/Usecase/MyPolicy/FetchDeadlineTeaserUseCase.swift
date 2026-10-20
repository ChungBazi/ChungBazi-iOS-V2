// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 메인 상단 티저: 마감이 다가오는 찜한 정책을 조회한다.
public protocol FetchDeadlineTeaserUseCase: Sendable {
    func execute() async throws -> [PolicySummary]
}
