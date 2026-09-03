// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 앱 설정(RemoteConfig) 접근. Splash 게이트 평가와 Profile 업데이트 인디케이터가 공유한다.
@DependencyClient
public struct AppConfigClient: Sendable {
    /// 서버 갱신 후 실행 게이트 평가(점검/강제업데이트/정상).
    public var evaluateGate: @Sendable () async -> AppLaunchGate = { .normal }
    /// 활성값 기준 현재 < latest 여부(네트워크 없음).
    public var isUpdateAvailable: @Sendable () -> Bool = { false }
}

extension AppConfigClient: TestDependencyKey {
    public static let testValue = AppConfigClient()
    public static let previewValue = AppConfigClient(
        evaluateGate: { .normal },
        isUpdateAvailable: { false }
    )
}

extension DependencyValues {
    public var appConfigClient: AppConfigClient {
        get { self[AppConfigClient.self] }
        set { self[AppConfigClient.self] = newValue }
    }
}
