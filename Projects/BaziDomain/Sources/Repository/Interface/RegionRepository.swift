// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol RegionRepository: Sendable {
    func fetchSidoList() async throws -> [RegionEntity]
    func fetchSigunguList(sidoCode: String) async throws -> [RegionEntity]
}
