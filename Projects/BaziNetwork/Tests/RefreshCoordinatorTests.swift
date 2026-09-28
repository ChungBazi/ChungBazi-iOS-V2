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
    private let result: Result<ReissueResponseDTO, NetworkError>
    private let lock = NSLock()
    private var _callCount = 0

    var callCount: Int { lock.withLock { _callCount } }

    init(result: Result<ReissueResponseDTO, NetworkError>) {
        self.result = result
    }

    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        lock.withLock { _callCount += 1 }
        return try result.get()
    }
}
