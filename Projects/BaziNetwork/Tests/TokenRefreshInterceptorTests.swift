// Copyright © 2026 ChungBazi. All rights reserved.

import Alamofire
import Foundation
import Testing

import BaziCore
@testable import BaziNetwork

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

private struct MockInterceptorTokenReissuer: TokenReissuer {
    func reissue(refreshToken: String) async throws -> ReissueResponseDTO {
        throw NetworkError.unauthorized
    }
}
