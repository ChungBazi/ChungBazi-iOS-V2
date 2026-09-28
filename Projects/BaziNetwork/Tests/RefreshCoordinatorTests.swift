// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Testing

import BaziCore
@testable import BaziNetwork

@Suite(.serialized)
struct RefreshCoordinatorTests {

    @Test("재발급 성공 시 .retry로 완료되고 새 토큰이 저장된다")
    func refresh_success_completesWithRetry() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "new-access", refreshToken: "new-refresh")))
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        let outcome = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        guard case .retry = outcome else {
            Issue.record("Expected .retry, got \(outcome)")
            return
        }
        #expect(reissuer.callCount == 1)
        #expect(storage.accessToken == "new-access")
        #expect(storage.refreshToken == "new-refresh")
    }

    @Test("재발급이 확정적 인증 실패(401/404)로 실패하면 .forceLogout으로 완료된다")
    func refresh_authFailure_completesWithForceLogout() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .failure(.unauthorized))
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        let outcome = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        guard case .forceLogout = outcome else {
            Issue.record("Expected .forceLogout, got \(outcome)")
            return
        }
    }

    @Test("재발급이 일시적 실패(5xx 등)로 실패하면 세션을 유지한 채 .keepSession으로 완료된다")
    func refresh_transientFailure_completesWithKeepSession() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .failure(.serverError(code: "COMMON500", message: "일시적 오류")))
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        let outcome = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        guard case .keepSession = outcome else {
            Issue.record("Expected .keepSession, got \(outcome)")
            return
        }
    }

    @Test("동시에 여러 요청이 들어와도 재발급은 1회만 실행되고 모든 completion이 .retry로 불린다")
    func refresh_concurrentCalls_singleFlight() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "new-access", refreshToken: "new-refresh")))
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        let requestCount = 10
        await withTaskGroup(of: RefreshCoordinator.Outcome.self) { group in
            for _ in 0..<requestCount {
                group.addTask {
                    await withCheckedContinuation { continuation in
                        coordinator.refresh { continuation.resume(returning: $0) }
                    }
                }
            }
            var outcomes: [RefreshCoordinator.Outcome] = []
            for await outcome in group {
                outcomes.append(outcome)
            }
            #expect(outcomes.count == requestCount)
            for outcome in outcomes {
                guard case .retry = outcome else {
                    Issue.record("Expected all outcomes to be .retry, got \(outcome)")
                    continue
                }
            }
        }

        #expect(reissuer.callCount == 1)
    }

    @Test("오프라인/타임아웃은 강제 로그아웃이 아니라 세션 유지로 완료된다")
    func refresh_offlineAndTimeout_completeWithKeepSession() async {
        for failure in [NetworkError.offline, NetworkError.timeout] {
            let storage = MockTokenStorage(refreshToken: "old-refresh")
            let reissuer = MockTokenReissuer(result: .failure(failure))
            let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

            let outcome = await withCheckedContinuation { continuation in
                coordinator.refresh { continuation.resume(returning: $0) }
            }

            guard case .keepSession = outcome else {
                Issue.record("Expected .keepSession for \(failure), got \(outcome)")
                continue
            }
        }
    }

    @Test("동시에 여러 요청이 확정적 인증 실패로 끝나도 강제 로그아웃 알림은 1회만 발생한다")
    func refresh_concurrentAuthFailure_notifiesForceLogoutOnce() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .failure(.unauthorized))
        // .default는 프로세스 전역이라 병렬로 도는 다른 테스트의 forceLogout과 섞일 수 있어,
        // 이 테스트 전용 NotificationCenter를 주입한다.
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        await confirmation(expectedCount: 1) { confirmForceLogout in
            let observer = notificationCenter.addObserver(
                forName: .forceLogout, object: nil, queue: nil
            ) { _ in confirmForceLogout() }
            defer { notificationCenter.removeObserver(observer) }

            await withTaskGroup(of: RefreshCoordinator.Outcome.self) { group in
                for _ in 0..<10 {
                    group.addTask {
                        await withCheckedContinuation { continuation in
                            coordinator.refresh { continuation.resume(returning: $0) }
                        }
                    }
                }
                for await outcome in group {
                    guard case .forceLogout = outcome else {
                        Issue.record("Expected .forceLogout, got \(outcome)")
                        continue
                    }
                }
            }
            // resolveAll의 notify는 completion 호출과 같은 동기 흐름 안에서 일어나지만,
            // continuation 재개 스케줄링과의 미세한 순서 차이를 흡수하기 위한 최소 유예.
            try? await Task.sleep(for: .milliseconds(50))
        }

        #expect(reissuer.callCount == 1)
    }

    @Test("notifyForceLogout을 여러 번 호출해도 알림은 1회만 발생한다")
    func notifyForceLogout_calledMultipleTimes_notifiesOnce() async {
        // TokenRefreshInterceptor의 retryCount>0 분기는 요청마다 독립적으로 notifyForceLogout을 호출하므로,
        // 동시에 여러 요청이 그 분기를 타면(실기기에서 실제로 확인됨) 이 메서드 자체가 멱등해야 한다.
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "a", refreshToken: "b")))
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        await confirmation(expectedCount: 1) { confirmForceLogout in
            let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { _ in
                confirmForceLogout()
            }
            defer { notificationCenter.removeObserver(observer) }

            coordinator.notifyForceLogout()
            coordinator.notifyForceLogout()
            coordinator.notifyForceLogout()

            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test("성공적인 재발급 이후에는 강제 로그아웃 알림이 다시 발생할 수 있다")
    func notifyForceLogout_afterSuccessfulRetry_canNotifyAgain() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "a", refreshToken: "b")))
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        coordinator.notifyForceLogout()

        _ = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        await confirmation(expectedCount: 1) { confirmForceLogout in
            let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { _ in
                confirmForceLogout()
            }
            defer { notificationCenter.removeObserver(observer) }

            coordinator.notifyForceLogout()

            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test("한 번 완료된 코디네이터는 이후 재발급 요청도 정상적으로 다시 처리한다")
    func refresh_afterPreviousCompletion_canRefreshAgain() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "first-access", refreshToken: "first-refresh")))
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        _ = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }
        #expect(reissuer.callCount == 1)

        reissuer.setResult(.success(.init(accessToken: "second-access", refreshToken: "second-refresh")))
        let secondOutcome = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        guard case .retry = secondOutcome else {
            Issue.record("Expected second refresh to also complete with .retry, got \(secondOutcome)")
            return
        }
        #expect(reissuer.callCount == 2)
        #expect(storage.accessToken == "second-access")
    }
}

// MARK: - Test Doubles

private final class MockTokenStorage: TokenStorage, @unchecked Sendable {
    var accessToken: String?
    var refreshToken: String?
    var hasSessionMarker: Bool = true

    init(refreshToken: String?) {
        self.refreshToken = refreshToken
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
    }
}

private final class MockTokenReissuer: TokenReissuer, @unchecked Sendable {
    private let lock = NSLock()
    private var result: Result<ReissueResponseDTO, NetworkError>
    private var _callCount = 0

    var callCount: Int { lock.withLock { _callCount } }

    init(result: Result<ReissueResponseDTO, NetworkError>) {
        self.result = result
    }

    func setResult(_ result: Result<ReissueResponseDTO, NetworkError>) {
        lock.withLock { self.result = result }
    }

    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        let currentResult = lock.withLock {
            _callCount += 1
            return result
        }
        return try currentResult.get()
    }
}
