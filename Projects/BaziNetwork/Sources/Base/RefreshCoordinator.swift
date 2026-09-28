// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

/// 토큰 재발급 single-flight 동시성 제어 — Alamofire 타입에 의존하지 않아 단위 테스트가 가능하다.
public final class RefreshCoordinator: @unchecked Sendable {

    public enum Outcome: Sendable {
        case retry
        case forceLogout(NetworkError)
        case keepSession(NetworkError)
    }

    private let tokenStorage: any TokenStorage
    private let tokenReissuer: any TokenReissuer
    private var isRefreshing = false
    private var pendingCompletion: [(Outcome) -> Void] = []
    // withLock 클로저 형태로만 사용 — async context에서 lock()/unlock() 분리 호출 금지 (Swift 6)
    private let lock = NSLock()

    public init(tokenStorage: any TokenStorage, tokenReissuer: any TokenReissuer) {
        self.tokenStorage = tokenStorage
        self.tokenReissuer = tokenReissuer
    }

    public func refresh(completion: @escaping (Outcome) -> Void) {
        // 동시에 여러 요청이 들어와도 reissue는 1회만 실행
        // 나머지는 pendingCompletion 큐에서 대기 후 결과를 함께 받는다
        let shouldRefresh = lock.withLock {
            pendingCompletion.append(completion)
            guard !isRefreshing else { return false }
            isRefreshing = true
            return true
        }

        guard shouldRefresh else { return }

        Task {
            do {
                guard let refreshToken = tokenStorage.refreshToken else {
                    throw NetworkError.unauthorized
                }
                let newTokens = try await tokenReissuer.reissue(refreshToken: refreshToken)
                tokenStorage.saveTokens(
                    accessToken: newTokens.accessToken,
                    refreshToken: newTokens.refreshToken
                )
                resolveAll(.retry)
            } catch {
                // TokenReissuer 구현체는 항상 NetworkError를 던지므로 이 캐스팅은 사실상 항상 성공한다.
                let networkError = error as? NetworkError ?? .unknown(error)
                // 확정적 인증 실패(401/404)만 강제 로그아웃한다.
                // 오프라인·타임아웃·서버오류(5xx)는 세션을 유지하고 재시도 가능한 오류로만 알린다.
                resolveAll(networkError.requiresForceLogout ? .forceLogout(networkError) : .keepSession(networkError))
            }
        }
    }

    private func resolveAll(_ outcome: Outcome) {
        lock.withLock {
            pendingCompletion.forEach { $0(outcome) }
            pendingCompletion.removeAll()
            isRefreshing = false
        }
    }
}
