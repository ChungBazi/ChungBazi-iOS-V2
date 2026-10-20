// Copyright © 2026 ChungBazi. All rights reserved.

import Alamofire
import Foundation
import BaziCore

// @unchecked Sendable: RefreshCoordinator가 자체적으로 lock으로 동시성을 보장한다.
public final class TokenRefreshInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenStorage: any TokenStorage
    private let refreshCoordinator: RefreshCoordinator

    public init(
        tokenStorage: any TokenStorage,
        tokenReissuer: any TokenReissuer = URLSessionTokenReissuer(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.tokenStorage = tokenStorage
        self.refreshCoordinator = RefreshCoordinator(
            tokenStorage: tokenStorage,
            tokenReissuer: tokenReissuer,
            notificationCenter: notificationCenter
        )
    }

    // 로그인/재발급처럼 인증이 필요 없는 엔드포인트. accessToken이 남아있어도 붙이지 않는다.
    private static let unauthenticatedPaths = ["/auth/kakao", "/auth/apple", "/auth/reissue"]

    // MARK: - adapt
    // 매 요청 전 호출. 인증이 필요 없는 엔드포인트는 accessToken 유무와 무관하게 헤더를 붙이지 않는다.
    public func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, Error>) -> Void
    ) {
        var request = urlRequest
        let path = urlRequest.url?.path ?? ""
        let isUnauthenticated = Self.unauthenticatedPaths.contains { path.hasSuffix($0) }
        if !isUnauthenticated, let token = tokenStorage.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(request))
    }

    // MARK: - retry
    // 401 수신 시 호출. reissue 성공 → 대기 중인 모든 요청 재시도, 실패 → 강제 로그아웃
    public func retry(
        _ request: Request,
        for session: Session,
        dueTo error: Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let path = request.request?.url?.path ?? ""
        let isUnauthenticated = Self.unauthenticatedPaths.contains { path.hasSuffix($0) }
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              // 로그인/재발급 요청의 401은 토큰 재발급 대상이 아니다.
              // (reissue는 무한루프 방지, 로그인은 세션이 없어 재발급이 무의미 + 불필요한 forceLogout 방지)
              !isUnauthenticated else {
            return completion(.doNotRetry)
        }

        guard request.retryCount == 0 else {
            // 재시도 후에도 401이면 세션이 깨진 것으로 본다.
            let networkError = NetworkError.unauthorized
            completion(.doNotRetryWithError(networkError))
            if networkError.requiresForceLogout {
                refreshCoordinator.notifyForceLogout(reason: .retryFailed)
            }
            return
        }

        // 동시 401 제어(single-flight)와 강제 로그아웃 판단·통지는 RefreshCoordinator가 전담한다.
        refreshCoordinator.refresh { outcome in
            switch outcome {
            case .retry:
                completion(.retry)
            case .failed(let networkError):
                completion(.doNotRetryWithError(networkError))
            }
        }
    }

    /// 새 로그인 완료 시 호출한다.
    public func sessionDidStart() {
        refreshCoordinator.sessionDidStart()
    }
}
