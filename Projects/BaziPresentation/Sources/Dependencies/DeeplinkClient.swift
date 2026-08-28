// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 앱 외부 진입(카카오 공유 링크 탭, 푸시 알림 탭)으로 도착하는 딥링크.
public enum Deeplink: Equatable, Sendable {
    case policyDetail(id: Int)
}

/// 딥링크 이벤트 스트림. Composition Root가 카카오 링크/푸시에서 파싱한 딥링크를 발행하고,
/// AppFeature가 구독해 해당 화면으로 라우팅한다. (forceLogout 이벤트와 동일한 브리지 방식)
@DependencyClient
public struct DeeplinkClient: Sendable {
    public var events: @Sendable () -> AsyncStream<Deeplink> = { AsyncStream { $0.finish() } }
    /// 콜드런치 대응: 아직 라우팅되지 못한(예: splash 단계에서 도착한) 딥링크를 꺼내며 비운다.
    public var takePending: @Sendable () -> Deeplink? = { nil }
}

extension DeeplinkClient: TestDependencyKey {
    public static let testValue = DeeplinkClient()
}

extension DependencyValues {
    public var deeplinkClient: DeeplinkClient {
        get { self[DeeplinkClient.self] }
        set { self[DeeplinkClient.self] = newValue }
    }
}
