// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore
@testable import BaziNetwork

final class MockTokenStorage: TokenStorage, @unchecked Sendable {
    var accessToken: String?
    var refreshToken: String?
    var hasSessionMarker: Bool = true

    init(accessToken: String? = nil, refreshToken: String? = nil) {
        self.accessToken = accessToken
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

final class MockTokenReissuer: TokenReissuer, @unchecked Sendable {
    private let lock = NSLock()
    private var result: Result<ReissueResponseDTO, NetworkError>
    private var _callCount = 0
    private let delay: Duration?
    private let gate: CountdownGate?

    var callCount: Int { lock.withLock { _callCount } }

    init(
        result: Result<ReissueResponseDTO, NetworkError> = .failure(.unauthorized),
        delay: Duration? = nil,
        gate: CountdownGate? = nil
    ) {
        self.result = result
        self.delay = delay
        self.gate = gate
    }

    func setResult(_ result: Result<ReissueResponseDTO, NetworkError>) {
        lock.withLock { self.result = result }
    }

    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        let currentResult = lock.withLock {
            _callCount += 1
            return result
        }
        if let gate {
            await gate.wait()
        } else if let delay {
            try? await Task.sleep(for: delay)
        }
        return try currentResult.get()
    }
}

/// 고정 지연 대신 "N개 등록 완료"라는 실제 신호로 동시성 테스트를 동기화하는 게이트.
final class CountdownGate: @unchecked Sendable {
    private let lock = NSLock()
    private let target: Int
    private var count = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(target: Int) {
        self.target = target
    }

    func increment() {
        let reached: [CheckedContinuation<Void, Never>] = lock.withLock {
            count += 1
            guard count >= target else { return [] }
            let waiting = waiters
            waiters.removeAll()
            return waiting
        }
        reached.forEach { $0.resume() }
    }

    func wait() async {
        let shouldWait: Bool = lock.withLock { count < target }
        guard shouldWait else { return }
        await withCheckedContinuation { continuation in
            let alreadyReached: Bool = lock.withLock {
                guard count < target else { return true }
                waiters.append(continuation)
                return false
            }
            if alreadyReached {
                continuation.resume()
            }
        }
    }
}

final class CapturedReason: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: String?

    var value: String? { lock.withLock { _value } }

    func set(_ value: String?) {
        lock.withLock { _value = value }
    }
}

final class Captured<Value>: @unchecked Sendable {
    private let lock = NSLock()
    private var _value: Value?

    var value: Value? { lock.withLock { _value } }

    func set(_ value: Value) {
        lock.withLock { _value = value }
    }
}
