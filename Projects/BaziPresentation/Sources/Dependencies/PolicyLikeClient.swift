// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 정책 찜/찜 해제를 담당하는 공용 Client. 홈·랭킹·분야별·맞춤 등 찜 UI가 있는 화면에서 공유한다.
@DependencyClient
public struct PolicyLikeClient: Sendable {
    /// liked=true면 찜, false면 찜 해제. 실패 시 throw → 호출부에서 낙관적 갱신을 롤백한다.
    public var setLike: @Sendable (_ policyId: Int, _ liked: Bool) async throws -> Void
}

extension PolicyLikeClient: TestDependencyKey {
    public static let testValue = PolicyLikeClient()

    public static let previewValue = PolicyLikeClient(setLike: { _, _ in })
}

extension DependencyValues {
    public var policyLikeClient: PolicyLikeClient {
        get { self[PolicyLikeClient.self] }
        set { self[PolicyLikeClient.self] = newValue }
    }
}
