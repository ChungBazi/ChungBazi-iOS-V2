// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 정책 메모 화면(22) 전용 Client. 메모 조회 + 작성/수정.
@DependencyClient
public struct PolicyMemoClient: Sendable {
    public var fetchMemo: @Sendable (_ policyId: Int) async throws -> PolicyMemoVO
    public var updateMemo: @Sendable (_ policyId: Int, _ memo: String) async throws -> Void
}

extension PolicyMemoClient: TestDependencyKey {
    public static let testValue = PolicyMemoClient()

    public static let previewValue = PolicyMemoClient(
        fetchMemo: { _ in PolicyMemoVO.mock },
        updateMemo: { _, _ in }
    )
}

extension DependencyValues {
    public var policyMemoClient: PolicyMemoClient {
        get { self[PolicyMemoClient.self] }
        set { self[PolicyMemoClient.self] = newValue }
    }
}
