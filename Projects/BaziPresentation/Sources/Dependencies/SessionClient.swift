// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@DependencyClient
public struct SessionClient: Sendable {
    /// 런타임 강제 로그아웃(.forceLogout) 이벤트 스트림.
    public var forceLogoutEvents: @Sendable () -> AsyncStream<Void> = { AsyncStream { $0.finish() } }
    /// 로컬 세션(토큰 + 상태) 초기화.
    public var resetSession: @Sendable () -> Void
    /// 로컬에 저장된 사용자 닉네임(없으면 nil).
    public var userName: @Sendable () -> String? = { nil }
}

extension SessionClient: TestDependencyKey {
    public static let testValue = SessionClient()
}

extension DependencyValues {
    public var sessionClient: SessionClient {
        get { self[SessionClient.self] }
        set { self[SessionClient.self] = newValue }
    }
}
