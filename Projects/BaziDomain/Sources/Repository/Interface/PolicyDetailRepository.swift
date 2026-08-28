// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 상세/카드 및 찜(like) 통신을 담당한다.
public protocol PolicyDetailRepository: Sendable {
    /// 정책 상세(추천 정책 포함)를 조회한다.
    func fetchPolicyDetail(policyId: Int) async throws -> PolicyDetail
    func fetchPolicyCard(policyId: Int) async throws -> PolicyCard
    /// 정책을 찜한다.
    func like(policyId: Int) async throws
    /// 정책 찜을 해제한다.
    func unlike(policyId: Int) async throws
}
