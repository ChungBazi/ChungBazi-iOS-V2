// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 선택된 시도(sidoCode)에 속한 시군구 목록을 조회한다.
public protocol FetchSigunguListUseCase: Sendable {
    func execute(sidoCode: String) async throws -> [RegionInfo]
}
