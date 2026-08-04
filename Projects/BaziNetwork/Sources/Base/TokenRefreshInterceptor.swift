// Copyright © 2026 ChungBazi. All rights reserved.

import Alamofire
import Foundation
import BaziCore

// @unchecked Sendable: NSLock으로 직접 thread-safety를 보장하므로 컴파일러 검사 해제
public final class TokenRefreshInterceptor: RequestInterceptor, @unchecked Sendable {
    private let tokenStorage: any TokenStorage
    private var isRefreshing = false
    private var pendingCompletion: [(RetryResult) -> Void] = []
    // withLock 클로저 형태로만 사용 — async context에서 lock()/unlock() 분리 호출 금지 (Swift 6)
    private let lock = NSLock()

    public init(tokenStorage: any TokenStorage) {
        self.tokenStorage = tokenStorage
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
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              // reissue 자체가 401이면 재시도하지 않음 → 무한루프 방지
              !(request.request?.url?.path.contains("/auth/reissue") ?? false) else {
            return completion(.doNotRetry)
        }

        // 동시에 401이 여러 개 와도 reissue는 1회만 실행
        // 나머지는 pendingCompletion 큐에서 대기 후 reissue 결과에 따라 일괄 처리
        let shouldRefresh = lock.withLock {
            pendingCompletion.append(completion)
            guard !isRefreshing else { return false }
            isRefreshing = true
            return true
        }

        guard shouldRefresh else { return }

        Task {
            do {
                let newTokens = try await reissueTokens()
                tokenStorage.saveTokens(
                    accessToken: newTokens.accessToken,
                    refreshToken: newTokens.refreshToken
                )
                lock.withLock {
                    pendingCompletion.forEach { $0(.retry) }
                    pendingCompletion.removeAll()
                    isRefreshing = false
                }
            } catch {
                lock.withLock {
                    pendingCompletion.forEach { $0(.doNotRetryWithError(NetworkError.unauthorized)) }
                    pendingCompletion.removeAll()
                    isRefreshing = false
                }
                await notifyForceLogout()
            }
        }
    }

    // MARK: - reissue
    // MoyaProvider/Session을 거치지 않고 URLSession 직접 호출
    // → 같은 interceptor를 통하면 401 → retry → 401 → retry 무한루프 발생
    private func reissueTokens() async throws -> ReissueResponseDTO {
        guard let refreshToken = tokenStorage.refreshToken else {
            throw NetworkError.unauthorized
        }

        let url = APIDomain.authURL.appendingPathComponent("reissue")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(refreshToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.unauthorized
        }

        let decoded = try JSONDecoder().decode(CommonResponse<ReissueResponseDTO>.self, from: data)
        guard decoded.isSuccess else {
            throw NetworkError.serverError(code: decoded.code, message: decoded.message)
        }
        return decoded.result
    }

    @MainActor
    private func notifyForceLogout() {
        NotificationCenter.default.post(name: .forceLogout, object: nil)
    }
}

public extension Notification.Name {
    static let forceLogout = Notification.Name("ChungBazi.forceLogout")
}
