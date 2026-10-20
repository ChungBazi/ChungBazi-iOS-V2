// Copyright © 2026 ChungBazi. All rights reserved.

import Testing

@testable import BaziDomain

private enum MockError: Error { case fail }

private struct MockRemoteConfigService: RemoteConfigService {
    let config: AppConfig
    var shouldFail = false
    func fetchAndActivate() async throws { if shouldFail { throw MockError.fail } }
    func currentConfig() -> AppConfig { config }
}

struct AppConfigUseCaseTests {

    private func config(
        server: Bool = false,
        min: String = "2.0.0",
        latest: String = "2.0.0",
        message: String = "점검"
    ) -> AppConfig {
        AppConfig(isServerCheck: server, minimumVersion: min, latestVersion: latest, serverCheckMessage: message)
    }

    @Test("점검이 최우선(강제업데이트 조건과 겹쳐도 점검)")
    func maintenanceTakesPrecedence() async {
        let sut = AppConfigUseCaseImpl(
            service: MockRemoteConfigService(config: config(server: true, min: "9.9.9")),
            currentVersion: "2.0.0"
        )
        #expect(await sut.evaluateGate() == .maintenance(message: "점검"))
    }

    @Test("최소버전 미만이면 강제 업데이트")
    func forceUpdateWhenBelowMinimum() async {
        let sut = AppConfigUseCaseImpl(
            service: MockRemoteConfigService(config: config(min: "2.1.0")),
            currentVersion: "2.0.0"
        )
        #expect(await sut.evaluateGate() == .forceUpdate)
    }

    @Test("최소버전 이상이면 정상")
    func normalWhenAtOrAboveMinimum() async {
        let sut = AppConfigUseCaseImpl(
            service: MockRemoteConfigService(config: config(min: "2.0.0")),
            currentVersion: "2.0.0"
        )
        #expect(await sut.evaluateGate() == .normal)
    }

    @Test("fetch 실패해도 캐시/기본값으로 게이트를 판정한다")
    func fetchFailureFallsThrough() async {
        let sut = AppConfigUseCaseImpl(
            service: MockRemoteConfigService(config: config(min: "2.1.0"), shouldFail: true),
            currentVersion: "2.0.0"
        )
        #expect(await sut.evaluateGate() == .forceUpdate)
    }

    @Test("현재 < latest면 업데이트 가용")
    func isUpdateAvailable() {
        #expect(AppConfigUseCaseImpl(
            service: MockRemoteConfigService(config: config(latest: "2.1.0")),
            currentVersion: "2.0.0"
        ).isUpdateAvailable())
        #expect(!AppConfigUseCaseImpl(
            service: MockRemoteConfigService(config: config(latest: "2.0.0")),
            currentVersion: "2.0.0"
        ).isUpdateAvailable())
    }
}
