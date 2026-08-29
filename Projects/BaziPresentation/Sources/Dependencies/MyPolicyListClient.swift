// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 내 정책 전체보기 화면(20) 전용 Client. 분야 필터 + 정렬 + 커서 페이지네이션.
@DependencyClient
public struct MyPolicyListClient: Sendable {
    public var fetchMyPolicies: @Sendable (_ category: PolicyCategoryUI?, _ sort: String, _ cursor: String?, _ size: Int) async throws -> PolicyPageVO
}

extension MyPolicyListClient: TestDependencyKey {
    public static let testValue = MyPolicyListClient()

    public static let previewValue = MyPolicyListClient(
        fetchMyPolicies: { _, _, _, _ in
            PolicyPageVO(
                policies: IdentifiedArray(uniqueElements: PolicySummaryVO.mockList),
                nextCursor: nil,
                hasNext: false,
                totalCount: PolicySummaryVO.mockList.count
            )
        }
    )
}

extension DependencyValues {
    public var myPolicyListClient: MyPolicyListClient {
        get { self[MyPolicyListClient.self] }
        set { self[MyPolicyListClient.self] = newValue }
    }
}
