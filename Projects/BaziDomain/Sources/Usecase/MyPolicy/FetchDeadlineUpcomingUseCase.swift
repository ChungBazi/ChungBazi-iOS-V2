// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 탭: 해당일 기준 2주 내 마감되는 찜한 정책을 조회한다(정렬·페이지네이션 없음, 총개수 포함).
public protocol FetchDeadlineUpcomingUseCase: Sendable {
    func execute(targetDate: String) async throws -> PolicyPage
}
