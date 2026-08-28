// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 정책 상세 화면 전용 Client. 상세(추천 정책 포함) 조회를 담당한다.
/// 찜은 공용 `PolicyLikeClient`를 재사용한다.
@DependencyClient
public struct PolicyDetailClient: Sendable {
    public var fetch: @Sendable (_ policyId: Int) async throws -> PolicyDetailVO
}

extension PolicyDetailClient: TestDependencyKey {
    public static let testValue = PolicyDetailClient()

    public static let previewValue = PolicyDetailClient(
        fetch: { .mock(id: $0) }
    )
}

extension DependencyValues {
    public var policyDetailClient: PolicyDetailClient {
        get { self[PolicyDetailClient.self] }
        set { self[PolicyDetailClient.self] = newValue }
    }
}
