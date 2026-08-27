// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 랭킹(인기/마감임박/새로 뜬) 화면 전용 Client. kind별 목록(커서 페이지네이션)을 담당한다.
@DependencyClient
public struct RankedPolicyClient: Sendable {
    public var fetchPopular: @Sendable (_ category: PolicyCategory?, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
    public var fetchDeadline: @Sendable (_ category: PolicyCategory?, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
    public var fetchLatest: @Sendable (_ category: PolicyCategory?, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
}

extension RankedPolicyClient: TestDependencyKey {
    public static let testValue = RankedPolicyClient()

    public static let previewValue: RankedPolicyClient = {
        let page: @Sendable (PolicyCategory?, String?, Int) async throws -> PolicyPageVO = { _, _, _ in
            PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: PolicySummary.mockList),
                nextCursor: nil,
                hasNext: false,
                totalCount: PolicySummary.mockList.count
            )
        }
        return RankedPolicyClient(fetchPopular: page, fetchDeadline: page, fetchLatest: page)
    }()
}

extension DependencyValues {
    public var rankedPolicyClient: RankedPolicyClient {
        get { self[RankedPolicyClient.self] }
        set { self[RankedPolicyClient.self] = newValue }
    }
}
