// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 분야별 정책 화면 전용 Client. 분야별 목록(페이지네이션)과 분야별 맞춤 티저를 담당한다.
@DependencyClient
public struct CategoryPolicyClient: Sendable {
    public var fetchPolicies: @Sendable (_ category: PolicyCategoryUI, _ sort: String, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
    public var fetchPersonalized: @Sendable (_ category: PolicyCategoryUI) async throws -> [PolicySummaryVO]
}

extension CategoryPolicyClient: TestDependencyKey {
    public static let testValue = CategoryPolicyClient()

    public static let previewValue = CategoryPolicyClient(
        fetchPolicies: { _, _, _, _ in
            PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: PolicySummaryVO.mockList),
                nextCursor: nil,
                hasNext: false,
                totalCount: PolicySummaryVO.mockList.count
            )
        },
        fetchPersonalized: { _ in Array(PolicySummaryVO.mockList.prefix(3)) }
    )
}

extension DependencyValues {
    public var categoryPolicyClient: CategoryPolicyClient {
        get { self[CategoryPolicyClient.self] }
        set { self[CategoryPolicyClient.self] = newValue }
    }
}
