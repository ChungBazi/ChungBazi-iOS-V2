// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 전국 시도 목록을 조회한다.
public protocol FetchSidoListUseCase: Sendable {
    func execute() async throws -> [RegionEntity]
}
