// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct PolicyDetailRepositoryImpl: PolicyDetailRepository {

    private let networkProvider: NetworkProvider
    private let cache: PolicyCache

    public init(networkProvider: NetworkProvider, cache: PolicyCache) {
        self.networkProvider = networkProvider
        self.cache = cache
    }

    public func fetchPolicyCard(policyId: Int) async throws -> PolicyCard {
        let dto: PolicyCardResponseDTO = try await networkProvider.request(
            PolicyDetailAPI.getPolicyCard(policyId: policyId)
        )
        return dto.toDomain()
    }

    public func like(policyId: Int) async throws {
        try await networkProvider.requestStatusCode(PolicyDetailAPI.likePolicy(policyId: policyId))
        // 홈 피드 캐시도 동기화해 다른 화면에서 찜해도 홈 복귀 시 반영되게 한다.
        await cache.updateLiked(policyId: policyId, liked: true)
    }

    public func unlike(policyId: Int) async throws {
        try await networkProvider.requestStatusCode(PolicyDetailAPI.unlikePolicy(policyId: policyId))
        await cache.updateLiked(policyId: policyId, liked: false)
    }
}
