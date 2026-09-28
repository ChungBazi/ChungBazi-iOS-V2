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
    private let notificationCenter: NotificationCenter
    private var isRefreshing = false
    private var pendingCompletion: [(Outcome) -> Void] = []
    private var hasNotifiedForceLogout = false
    // withLock 클로저 형태로만 사용 — async context에서 lock()/unlock() 분리 호출 금지 (Swift 6)
    private let lock = NSLock()

    public init(
        tokenStorage: any TokenStorage,
        tokenReissuer: any TokenReissuer,
        notificationCenter: NotificationCenter = .default
    ) {
        self.tokenStorage = tokenStorage
        self.tokenReissuer = tokenReissuer
        self.notificationCenter = notificationCenter
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
            if case .retry = outcome {
                // 세션이 다시 살아났으니, 이후에 또 끊기면 강제 로그아웃을 다시 통지할 수 있어야 한다.
                hasNotifiedForceLogout = false
            }
        }
        if case .forceLogout = outcome {
            notifyForceLogout()
        }
    }

    /// retryCount 초과 등 single-flight 경로를 거치지 않는 확정적 실패도 같은 알림 채널을 쓰도록 노출한다.
    /// 여러 경로에서 동시에 호출돼도(예: 재시도한 여러 요청이 동시에 또 401을 받는 경우) 세션당 1회만 통지한다.
    public func notifyForceLogout() {
        let shouldNotify = lock.withLock {
            guard !hasNotifiedForceLogout else { return false }
            hasNotifiedForceLogout = true
            return true
        }
        guard shouldNotify else { return }
        notificationCenter.post(name: .forceLogout, object: nil)
    }
}

public extension Notification.Name {
    static let forceLogout = Notification.Name("ChungBazi.forceLogout")
}
