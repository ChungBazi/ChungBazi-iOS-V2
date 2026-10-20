// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Testing

import BaziCore
@testable import BaziStorage

struct SessionHostGuardTests {

    private let devHost = "dev.example.com"
    private let prodHost = "api.example.com"

    @Test("호스트 기록이 없는 기존 설치는 세션을 유지하고 현재 호스트를 기록한다")
    func bind_withoutStoredHost_keepsSession() {
        let (sut, tokenStorage, userDefaultsStorage) = makeSUT()
        userDefaultsStorage.hasSetNickname = true

        sut.bind(to: prodHost)

        #expect(tokenStorage.accessToken == "access")
        #expect(tokenStorage.refreshToken == "refresh")
        #expect(tokenStorage.hasSessionMarker)
        #expect(userDefaultsStorage.hasSetNickname)
        #expect(userDefaultsStorage.sessionHost == prodHost)
    }

    @Test("저장된 호스트와 같으면 세션을 유지한다")
    func bind_withSameHost_keepsSession() {
        let (sut, tokenStorage, userDefaultsStorage) = makeSUT()
        userDefaultsStorage.sessionHost = prodHost

        sut.bind(to: prodHost)

        #expect(tokenStorage.accessToken == "access")
        #expect(tokenStorage.refreshToken == "refresh")
        #expect(tokenStorage.hasSessionMarker)
        #expect(userDefaultsStorage.sessionHost == prodHost)
    }

    @Test("저장된 호스트와 다르면 토큰과 세션 마커를 지우고 새 호스트를 기록한다")
    func bind_withDifferentHost_clearsSession() {
        let (sut, tokenStorage, userDefaultsStorage) = makeSUT()
        userDefaultsStorage.sessionHost = devHost

        sut.bind(to: prodHost)

        #expect(tokenStorage.accessToken == nil)
        #expect(tokenStorage.refreshToken == nil)
        #expect(!tokenStorage.hasSessionMarker)
        #expect(userDefaultsStorage.sessionHost == prodHost)
    }

    @Test("호스트가 바뀌면 닉네임·온보딩 등 세션 상태도 초기화한다")
    func bind_withDifferentHost_resetsSessionState() {
        let (sut, _, userDefaultsStorage) = makeSUT()
        userDefaultsStorage.sessionHost = devHost
        userDefaultsStorage.hasSetNickname = true
        userDefaultsStorage.hasCompletedOnboarding = true
        userDefaultsStorage.userName = "tester"

        sut.bind(to: prodHost)

        #expect(!userDefaultsStorage.hasSetNickname)
        #expect(!userDefaultsStorage.hasCompletedOnboarding)
        #expect(userDefaultsStorage.userName == nil)
    }

    @Test("호스트를 바꿨다가 되돌려도 폐기된 세션은 되살아나지 않는다")
    func bind_switchingBack_doesNotRestoreSession() {
        let (sut, tokenStorage, userDefaultsStorage) = makeSUT()
        userDefaultsStorage.sessionHost = devHost

        sut.bind(to: prodHost)
        sut.bind(to: devHost)

        #expect(tokenStorage.refreshToken == nil)
        #expect(!tokenStorage.hasSessionMarker)
        #expect(userDefaultsStorage.sessionHost == devHost)
    }

    // MARK: - Helpers

    private func makeSUT() -> (SessionHostGuard, SpyTokenStorage, UserDefaultsStorage) {
        let suiteName = "SessionHostGuardTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        let userDefaultsStorage = UserDefaultsStorage(defaults: defaults)
        let tokenStorage = SpyTokenStorage(accessToken: "access", refreshToken: "refresh")
        let sut = SessionHostGuard(tokenStorage: tokenStorage, userDefaultsStorage: userDefaultsStorage)
        return (sut, tokenStorage, userDefaultsStorage)
    }
}

/// 로그인된 상태(토큰 + 세션 마커)에서 시작하는 TokenStorage 대역.
private final class SpyTokenStorage: TokenStorage, @unchecked Sendable {
    private(set) var accessToken: String?
    private(set) var refreshToken: String?
    private(set) var hasSessionMarker = true

    init(accessToken: String?, refreshToken: String?) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }

    func saveTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        hasSessionMarker = true
    }

    func clearTokens() {
        accessToken = nil
        refreshToken = nil
        hasSessionMarker = false
    }
}
