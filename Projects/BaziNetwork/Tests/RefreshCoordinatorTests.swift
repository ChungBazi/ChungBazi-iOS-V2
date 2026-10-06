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

        guard case .failed(let networkError) = outcome, networkError.requiresForceLogout else {
            Issue.record("Expected a force-logout-requiring failure, got \(outcome)")
            return
        }
    }

    @Test("재발급이 일시적 실패(5xx 등)로 실패하면 세션을 유지한 채 강제 로그아웃 대상이 아닌 .failed로 완료된다")
    func refresh_transientFailure_completesWithKeepSession() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .failure(.serverError(code: "COMMON500", message: "일시적 오류")))
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        let outcome = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        guard case .failed(let networkError) = outcome, !networkError.requiresForceLogout else {
            Issue.record("Expected a non-force-logout failure, got \(outcome)")
            return
        }
    }

    @Test("동시에 여러 요청이 들어와도 재발급은 1회만 실행되고 모든 completion이 .retry로 불린다")
    func refresh_concurrentCalls_singleFlight() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        // 디스패치된 10개가 모두 도착할 시간을 벌어준다 — 지연이 없으면 시스템이 바쁠 때 몇 개가
        // single-flight 윈도우를 놓쳐 재발급이 2회로 늘어나는 타이밍 플레이키가 생긴다.
        let reissuer = MockTokenReissuer(
            result: .success(.init(accessToken: "new-access", refreshToken: "new-refresh")),
            delay: .milliseconds(30)
        )
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

            guard case .failed(let networkError) = outcome, !networkError.requiresForceLogout else {
                Issue.record("Expected a non-force-logout failure for \(failure), got \(outcome)")
                continue
            }
        }
    }

    @Test("동시에 여러 요청이 확정적 인증 실패로 끝나도 강제 로그아웃 알림은 1회만 발생한다")
    func refresh_concurrentAuthFailure_notifiesForceLogoutOnce() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        // 디스패치된 10개가 모두 도착할 시간을 벌어준다 — 지연이 없으면 시스템이 바쁠 때 몇 개가
        // single-flight 윈도우를 놓쳐 재발급이 2회로 늘어나는 타이밍 플레이키가 생긴다.
        let reissuer = MockTokenReissuer(result: .failure(.unauthorized), delay: .milliseconds(30))
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
                    guard case .failed(let networkError) = outcome, networkError.requiresForceLogout else {
                        Issue.record("Expected a force-logout-requiring failure, got \(outcome)")
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

    @Test("재발급 자체가 실패해 강제 로그아웃될 때, 알림에 reason=refresh_failed가 실린다")
    func resolveAll_forceLogout_postsRefreshFailedReason() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .failure(.unauthorized))
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        let capturedReason = CapturedReason()
        let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { notification in
            capturedReason.set(notification.userInfo?[ForceLogoutUserInfoKey.reason] as? String)
        }
        defer { notificationCenter.removeObserver(observer) }

        _ = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }
        try? await Task.sleep(for: .milliseconds(50))

        #expect(capturedReason.value == RefreshCoordinator.ForceLogoutReason.refreshFailed.rawValue)
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

            coordinator.notifyForceLogout(reason: .retryFailed)
            coordinator.notifyForceLogout(reason: .retryFailed)
            coordinator.notifyForceLogout(reason: .retryFailed)

            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test("성공적인 재발급 이후에는 강제 로그아웃 알림이 다시 발생할 수 있다")
    func notifyForceLogout_afterSuccessfulRetry_canNotifyAgain() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "a", refreshToken: "b")))
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        coordinator.notifyForceLogout(reason: .retryFailed)

        _ = await withCheckedContinuation { continuation in
            coordinator.refresh { continuation.resume(returning: $0) }
        }

        await confirmation(expectedCount: 1) { confirmForceLogout in
            let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { _ in
                confirmForceLogout()
            }
            defer { notificationCenter.removeObserver(observer) }

            coordinator.notifyForceLogout(reason: .retryFailed)

            try? await Task.sleep(for: .milliseconds(50))
        }
    }

    @Test("강제 로그아웃이 결정된 후에는, 그 전에 시작된 재발급이 늦게 성공해도 토큰을 저장하지 않는다")
    func refresh_succeedsAfterForceLogoutDeclared_discardsStaleSuccess() async {
        let storage = MockTokenStorage(accessToken: "old-access", refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(
            result: .success(.init(accessToken: "new-access", refreshToken: "new-refresh")),
            delay: .milliseconds(30)
        )
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer)

        let outcome = await withCheckedContinuation { continuation in
            // retryCount>0 분기처럼 single-flight를 거치지 않고 독립적으로 세션을 죽이는 경로를 흉내낸다.
            coordinator.refresh { continuation.resume(returning: $0) }
            coordinator.notifyForceLogout(reason: .retryFailed)
        }

        guard case .failed = outcome else {
            Issue.record("Expected .failed (stale success discarded), got \(outcome)")
            return
        }
        // 늦게 도착한 성공 결과가 세션을 되살리면 안 된다.
        #expect(storage.accessToken == "old-access")
        #expect(storage.refreshToken == "old-refresh")
    }

    @Test("완료 핸들러에서 재진입한 refresh는 새 세대로 취급되어 정상적으로 성공한다")
    func resolveAll_reentrantRefreshDuringCompletion_treatedAsFreshGenerationAndSucceeds() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .failure(.unauthorized))
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        let reentrantOutcome = Captured<RefreshCoordinator.Outcome>()

        await confirmation(expectedCount: 1) { confirmForceLogout in
            let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { _ in
                confirmForceLogout()
            }
            defer { notificationCenter.removeObserver(observer) }

            await withCheckedContinuation { continuation in
                coordinator.refresh { outcome in
                    // 완료 핸들러 안에서 재진입 — 이번엔 성공하는 새 사이클을 시작시킨다.
                    reissuer.setResult(.success(.init(accessToken: "new-access", refreshToken: "new-refresh")))
                    coordinator.refresh { reentrantOutcome.set($0) }
                    continuation.resume()
                }
            }

            try? await Task.sleep(for: .milliseconds(50))
        }

        guard case .retry = reentrantOutcome.value else {
            Issue.record("Expected reentrant refresh to succeed with .retry, got \(String(describing: reentrantOutcome.value))")
            return
        }
        #expect(storage.accessToken == "new-access")
    }

    @Test("sessionDidStart 이후에는 강제 로그아웃 알림이 다시 발생할 수 있다")
    func notifyForceLogout_afterSessionDidStart_canNotifyAgain() async {
        let storage = MockTokenStorage(refreshToken: "old-refresh")
        let reissuer = MockTokenReissuer(result: .success(.init(accessToken: "a", refreshToken: "b")))
        let notificationCenter = NotificationCenter()
        let coordinator = RefreshCoordinator(tokenStorage: storage, tokenReissuer: reissuer, notificationCenter: notificationCenter)

        coordinator.notifyForceLogout(reason: .retryFailed)
        try? await Task.sleep(for: .milliseconds(50))

        coordinator.sessionDidStart()

        await confirmation(expectedCount: 1) { confirmForceLogout in
            let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { _ in
                confirmForceLogout()
            }
            defer { notificationCenter.removeObserver(observer) }

            coordinator.notifyForceLogout(reason: .retryFailed)

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
// MockTokenStorage/MockTokenReissuer/CapturedReason는 SessionTestDoubles.swift에서 공유한다.
