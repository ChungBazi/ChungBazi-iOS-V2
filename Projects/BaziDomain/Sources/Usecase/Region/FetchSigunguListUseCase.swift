// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol FetchSigunguListUseCase: Sendable {
    func execute(sidoCode: String) async throws -> [RegionEntity]
}
