// Copyright © 2026 ChungBazi. All rights reserved.

import Alamofire
import Foundation
import Testing

import BaziCore
@testable import BaziNetwork

@Suite(.serialized)
struct TokenRefreshInterceptorTests {

    @Test("일반 엔드포인트는 accessToken이 있으면 Authorization 헤더를 붙인다")
    func adapt_normalPath_attachesAuthorizationHeader() async {
        let storage = MockInterceptorTokenStorage(accessToken: "the-access-token")
        let interceptor = TokenRefreshInterceptor(
            tokenStorage: storage,
            tokenReissuer: MockInterceptorTokenReissuer()
        )
        let request = URLRequest(url: URL(string: "https://api.chungbazi.store/api/v1/notifications")!)

        let adapted = await adapt(request, with: interceptor)

        guard case let .success(adaptedRequest) = adapted else {
            Issue.record("Expected adapt to succeed, got \(adapted)")
            return
        }
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == "Bearer the-access-token")
    }

    @Test("로그인/재발급 엔드포인트는 accessToken이 있어도 Authorization 헤더를 붙이지 않는다")
    func adapt_unauthenticatedPath_neverAttachesAuthorizationHeader() async {
        let storage = MockInterceptorTokenStorage(accessToken: "the-access-token")
        let interceptor = TokenRefreshInterceptor(
            tokenStorage: storage,
            tokenReissuer: MockInterceptorTokenReissuer()
        )
        let paths = [
            "https://api.chungbazi.store/api/v1/auth/kakao",
            "https://api.chungbazi.store/api/v1/auth/apple",
            "https://api.chungbazi.store/api/v1/auth/reissue",
        ]

        for path in paths {
            let request = URLRequest(url: URL(string: path)!)
            let adapted = await adapt(request, with: interceptor)

            guard case let .success(adaptedRequest) = adapted else {
                Issue.record("Expected adapt to succeed for \(path), got \(adapted)")
                continue
            }
            #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == nil, "\(path)에 Authorization이 붙으면 안 됨")
        }
    }

    @Test("accessToken이 없으면 일반 엔드포인트에도 Authorization 헤더를 붙이지 않는다")
    func adapt_noAccessToken_doesNotAttachAuthorizationHeader() async {
        let storage = MockInterceptorTokenStorage(accessToken: nil)
        let interceptor = TokenRefreshInterceptor(
            tokenStorage: storage,
            tokenReissuer: MockInterceptorTokenReissuer()
        )
        let request = URLRequest(url: URL(string: "https://api.chungbazi.store/api/v1/notifications")!)

        let adapted = await adapt(request, with: interceptor)

        guard case let .success(adaptedRequest) = adapted else {
            Issue.record("Expected adapt to succeed, got \(adapted)")
            return
        }
        #expect(adaptedRequest.value(forHTTPHeaderField: "Authorization") == nil)
    }

    @Test("재발급에 성공해 재시도해도 또 401이면 더 재시도하지 않고 강제 로그아웃한다")
    func retry_afterSuccessfulReissueStillGets401_forceLogsOutWithoutFurtherRetry() async throws {
        // 목표 엔드포인트는 항상 401만 반환하도록 스텁 — reissue는 성공하지만 재시도한 원 요청은 계속 401이 오는 상황을 재현한다.
        MockURLProtocol.statusCode = 401

        let storage = MockInterceptorTokenStorage(accessToken: "old-access")
        storage.refreshToken = "old-refresh"
        let reissuer = MockInterceptorTokenReissuer(
            result: .success(.init(accessToken: "new-access", refreshToken: "new-refresh"))
        )
        // .default는 프로세스 전역이라 병렬로 도는 다른 테스트(RefreshCoordinatorTests 등)의 forceLogout과
        // 섞일 수 있어, 이 테스트 전용 NotificationCenter를 주입한다.
        let notificationCenter = NotificationCenter()
        let interceptor = TokenRefreshInterceptor(
            tokenStorage: storage,
            tokenReissuer: reissuer,
            notificationCenter: notificationCenter
        )

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = Session(configuration: configuration, interceptor: interceptor)

        let forceLogoutCount = Counter()
        let observer = notificationCenter.addObserver(forName: .forceLogout, object: nil, queue: nil) { _ in
            forceLogoutCount.increment()
        }
        defer { notificationCenter.removeObserver(observer) }

        // Moya의 validationType(.successCodes)이 프로덕션에서 하는 걸 raw Alamofire에서는 .validate()로 직접 해줘야
        // 401을 "실패"로 인식해서 retry()가 호출된다. 없으면 401도 그냥 성공 응답으로 흘러가 재발급 자체가 트리거되지 않는다.
        let response = await session
            .request(URL(string: "https://mock.chungbazi.test/api/v1/notifications")!)
            .validate()
            .serializingData()
            .response

        #expect(response.response?.statusCode == 401)
        // 재발급은 정확히 1번만 시도되고(재시도가 또 401이어도 재재발급하지 않음), 성공한 새 토큰은 저장된다.
        #expect(reissuer.callCount == 1)
        #expect(storage.accessToken == "new-access")
        // resolveAll과 달리 이 분기는 동기적으로 알림을 보내지만, 스케줄링 여유를 위해 짧게 대기한다.
        try? await Task.sleep(for: .milliseconds(50))
        #expect(forceLogoutCount.value == 1)
    }

    // MARK: - Helper

    private func adapt(_ request: URLRequest, with interceptor: TokenRefreshInterceptor) async -> Result<URLRequest, Error> {
        await withCheckedContinuation { continuation in
            interceptor.adapt(request, for: Session()) { result in
                continuation.resume(returning: result)
            }
        }
    }
}

// MARK: - Test Doubles

private final class MockInterceptorTokenStorage: TokenStorage, @unchecked Sendable {
    var accessToken: String?
    var refreshToken: String?
    var hasSessionMarker: Bool = true

    init(accessToken: String?) {
        self.accessToken = accessToken
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

private final class MockInterceptorTokenReissuer: TokenReissuer, @unchecked Sendable {
    private let lock = NSLock()
    private let result: Result<ReissueResponseDTO, NetworkError>
    private var _callCount = 0

    var callCount: Int { lock.withLock { _callCount } }

    init(result: Result<ReissueResponseDTO, NetworkError> = .failure(.unauthorized)) {
        self.result = result
    }

    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        lock.withLock { _callCount += 1 }
        return try result.get()
    }
}

/// 목표 엔드포인트로 가는 모든 요청에 동일한 status code를 스텁한다. reissue는 TokenReissuer mock으로 대체되므로
/// 실제 네트워크 스텁 대상은 "재시도 대상 원 요청" 하나뿐이라 상태를 전역으로 둬도 안전하다(.serialized suite).
final class MockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var statusCode = 401

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data("{}".utf8))
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private final class Counter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value = 0

    var value: Int { lock.withLock { _value } }

    func increment() {
        lock.withLock { _value += 1 }
    }
}
