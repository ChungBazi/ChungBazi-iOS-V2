// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버와의 지역(시도/시군구) 데이터 통신을 담당한다.
public protocol RegionRepository: Sendable {
    func fetchSidoList() async throws -> [RegionInfo]
    func fetchSigunguList(sidoCode: String) async throws -> [RegionInfo]
}
