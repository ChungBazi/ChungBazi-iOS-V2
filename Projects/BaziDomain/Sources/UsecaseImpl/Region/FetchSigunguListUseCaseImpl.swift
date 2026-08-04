// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchSigunguListUseCaseImpl: FetchSigunguListUseCase {

    private let regionRepository: RegionRepository

    public init(regionRepository: RegionRepository) {
        self.regionRepository = regionRepository
    }

    /// 가나다순 Sorting
    public func execute(sidoCode: String) async throws -> [RegionInfo] {
        let list = try await regionRepository.fetchSigunguList(sidoCode: sidoCode)
        return list.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}
