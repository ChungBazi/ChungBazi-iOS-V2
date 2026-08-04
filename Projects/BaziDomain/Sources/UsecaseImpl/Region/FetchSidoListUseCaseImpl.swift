// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchSidoListUseCaseImpl: FetchSidoListUseCase {

    private let regionRepository: RegionRepository

    public init(regionRepository: RegionRepository) {
        self.regionRepository = regionRepository
    }

    /// 가나다순 Sorting
    public func execute() async throws -> [RegionEntity] {
        let list = try await regionRepository.fetchSidoList()
        return list.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}
