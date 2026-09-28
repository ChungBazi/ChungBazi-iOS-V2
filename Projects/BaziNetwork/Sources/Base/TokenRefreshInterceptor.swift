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
        let path = request.request?.url?.path ?? ""
        let isUnauthenticated = Self.unauthenticatedPaths.contains { path.hasSuffix($0) }
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401,
              // 로그인/재발급 요청의 401은 토큰 재발급 대상이 아니다.
              // (reissue는 무한루프 방지, 로그인은 세션이 없어 재발급이 무의미 + 불필요한 forceLogout 방지)
              !isUnauthenticated,
              // 재발급 후 재시도가 또 401이면 그만둔다 — 새 토큰도 거부당하는 경우의 무한 재발급 루프 방지.
              request.retryCount == 0 else {
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
                // reissueTokens()는 항상 NetworkError를 던지므로 이 캐스팅은 사실상 항상 성공한다.
                let networkError = error as? NetworkError ?? .unknown(error)
                lock.withLock {
                    pendingCompletion.forEach { $0(.doNotRetryWithError(networkError)) }
                    pendingCompletion.removeAll()
                    isRefreshing = false
                }
                // 확정적 인증 실패(401/404)만 강제 로그아웃한다.
                // 오프라인·타임아웃·서버오류(5xx)는 세션을 유지하고 재시도 가능한 오류로만 알린다.
                if networkError.requiresForceLogout {
                    await notifyForceLogout()
                }
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
        // 서버 계약: refreshToken은 body로만 받는다. Authorization 헤더에 refreshToken을 실으면
        // 서버 인증 필터가 이를 access token으로 검증하려다 401을 내어 강제 로그아웃되므로 붙이지 않는다.
        urlRequest.httpBody = try JSONEncoder().encode(ReissueRequestDTO(refreshToken: refreshToken))

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: urlRequest)
        } catch {
            // 오프라인·타임아웃 등 네트워크 레벨 실패. 확정적 인증 실패가 아니므로 세션은 유지한다.
            throw NetworkError.from(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(URLError(.badServerResponse))
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            let body = String(data: data, encoding: .utf8)?.prefix(300) ?? ""
            Log.error("토큰 재발급 실패: status=\(httpResponse.statusCode) body=\(body)", category: .auth)
            // 401/404는 확정적 인증 실패(강제 로그아웃), 5xx 등은 일시적 실패(세션 유지)로 분류한다.
            throw ReissueFailureClassifier.classify(statusCode: httpResponse.statusCode, data: data)
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
