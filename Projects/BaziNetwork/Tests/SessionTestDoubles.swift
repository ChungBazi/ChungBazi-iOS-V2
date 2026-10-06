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

    var callCount: Int { lock.withLock { _callCount } }

    init(result: Result<ReissueResponseDTO, NetworkError> = .failure(.unauthorized), delay: Duration? = nil) {
        self.result = result
        self.delay = delay
    }

    func setResult(_ result: Result<ReissueResponseDTO, NetworkError>) {
        lock.withLock { self.result = result }
    }

    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        let currentResult = lock.withLock {
            _callCount += 1
            return result
        }
        if let delay {
            try? await Task.sleep(for: delay)
        }
        return try currentResult.get()
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
