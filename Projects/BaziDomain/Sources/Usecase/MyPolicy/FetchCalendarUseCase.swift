// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 특정 달의 마감일들을 조회한다(캘린더 인디케이터용).
public protocol FetchCalendarUseCase: Sendable {
    func execute(targetMonth: String) async throws -> [Date]
}
