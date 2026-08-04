// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct RegionRepositoryImpl: RegionRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func fetchSidoList() async throws -> [RegionEntity] {
        let dtos: [SidoResponseDTO] = try await networkProvider.request(RegionAPI.getSido)
        return dtos.map { $0.toDomain() }
    }

    public func fetchSigunguList(sidoCode: String) async throws -> [RegionEntity] {
        let dtos: [SigunguResponseDTO] = try await networkProvider.request(RegionAPI.getSigungu(sido: sidoCode))
        return dtos.map { $0.toDomain() }
    }
}
