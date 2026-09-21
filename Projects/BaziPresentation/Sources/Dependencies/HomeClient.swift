// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 홈 메인 화면 전용 Client. 홈 aggregate 피드 조회와 안읽음 알림 배지 상태 조회를 담당한다.
@DependencyClient
public struct HomeClient: Sendable {
    public var fetchHomeFeed: @Sendable (_ forceRefresh: Bool) async throws -> HomeFeedVO
    public var fetchUnreadStatus: @Sendable () async throws -> Bool
}

extension HomeClient: TestDependencyKey {
    public static let testValue = HomeClient()

    public static let previewValue = HomeClient(
        fetchHomeFeed: { _ in .mock },
        fetchUnreadStatus: { true }
    )
}

extension DependencyValues {
    public var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
