// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct HomeRepositoryImpl: HomeRepository {

    private let networkProvider: NetworkProvider
    private let cache: PolicyCache

    public init(networkProvider: NetworkProvider, cache: PolicyCache) {
        self.networkProvider = networkProvider
        self.cache = cache
    }

    // 홈 섹션만 캐시 경유. forceRefresh면 캐시 읽기를 건너뛰고 최신으로 덮어쓴다.
    public func fetchHomeFeed(forceRefresh: Bool) async throws -> HomeFeed {
        if !forceRefresh, let cached = await cache.homeFeed() {
            return cached
        }
        let dto: HomePolicySectionResponseDTO = try await networkProvider.request(HomeAPI.getHomePolicySection)
        let feed = dto.toDomain()
        await cache.setHomeFeed(feed)
        return feed
    }

    // 아래 리스트들은 캐시하지 않고 항상 네트워크 조회한다.
    public func fetchPersonalizedPolicies(category: PolicyCategory) async throws -> [PolicySummary] {
        let dto: PersonalizedPolicyResponseDTO = try await networkProvider.request(
            HomeAPI.getPersonalizedPolicies(category: category.rawValue)
        )
        return dto.policies.map { $0.toDomain() }
    }

    public func fetchCategoryPolicies(category: PolicyCategory, sort: String, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            HomeAPI.getPolicies(category: category.rawValue, sort: sort, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func fetchPopularPolicies(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            HomeAPI.getPopularPolicies(category: category?.rawValue, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func fetchDeadlinePolicies(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            HomeAPI.getDeadlinePolicies(category: category?.rawValue, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func fetchLatestPolicies(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            HomeAPI.getLatestPolicies(category: category?.rawValue, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }
}
