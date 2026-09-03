// Copyright © 2026 ChungBazi. All rights reserved.

/// RemoteConfig(SDK) 접근. `fetchAndActivate`로 서버 갱신(스로틀 적용),
/// `currentConfig`로 활성화된 값을 로컬에서 읽는다(네트워크 없음).
public protocol RemoteConfigService: Sendable {
    func fetchAndActivate() async throws
    func currentConfig() -> AppConfig
}
