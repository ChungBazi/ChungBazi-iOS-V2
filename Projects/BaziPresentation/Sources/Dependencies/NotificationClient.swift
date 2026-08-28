// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 알림 목록 화면 전용 Client. 커서 페이지네이션 조회(탭 필터 포함) + 삭제를 담당한다.
@DependencyClient
public struct NotificationClient: Sendable {
    public var fetch: @Sendable (_ category: String?, _ cursor: Int?, _ size: Int) async throws -> NotificationPageVO
    public var delete: @Sendable (_ id: Int) async throws -> Void
    public var deleteAll: @Sendable () async throws -> Void
}

extension NotificationClient: TestDependencyKey {
    public static let testValue = NotificationClient()

    public static let previewValue = NotificationClient(
        fetch: { _, _, _ in .mock },
        delete: { _ in },
        deleteAll: {}
    )
}

extension DependencyValues {
    public var notificationClient: NotificationClient {
        get { self[NotificationClient.self] }
        set { self[NotificationClient.self] = newValue }
    }
}
