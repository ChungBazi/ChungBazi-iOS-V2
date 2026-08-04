// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol FetchSidoListUseCase: Sendable {
    func execute() async throws -> [RegionEntity]
}
