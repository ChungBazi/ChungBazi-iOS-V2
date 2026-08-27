// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct PolicyDetailRepositoryImpl: PolicyDetailRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func fetchPolicyCard(policyId: Int) async throws -> PolicyCard {
        let dto: PolicyCardResponseDTO = try await networkProvider.request(
            PolicyDetailAPI.getPolicyCard(policyId: policyId)
        )
        return dto.toDomain()
    }
}
