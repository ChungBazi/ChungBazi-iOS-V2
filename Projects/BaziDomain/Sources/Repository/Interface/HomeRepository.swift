// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 홈 정책 데이터 통신을 담당한다. 홈 섹션(aggregate)만 캐싱하고 리스트는 항상 네트워크 조회한다.
public protocol HomeRepository: Sendable {
    func fetchHomeFeed(forceRefresh: Bool) async throws -> HomeFeed
    func fetchPersonalizedPolicies(category: PolicyCategory) async throws -> [PolicySummary]
    func fetchCategoryPolicies(category: PolicyCategory, sort: String, cursor: String?, size: Int) async throws -> PolicyPage
    func fetchPopularPolicies(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage
    func fetchDeadlinePolicies(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage
    func fetchLatestPolicies(category: PolicyCategory?, cursor: String?, size: Int) async throws -> PolicyPage
}
