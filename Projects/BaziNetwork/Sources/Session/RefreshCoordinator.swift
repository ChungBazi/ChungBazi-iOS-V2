// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore

/// 토큰 재발급 single-flight 동시성 제어 — Alamofire 타입에 의존하지 않아 단위 테스트가 가능하다.
public final class RefreshCoordinator: @unchecked Sendable {

    public enum Outcome: Sendable {
        case retry
        case failed(NetworkError)
    }

    /// 강제 로그아웃 원인 태그 — Amplitude `force_logout` 이벤트의 `reason`으로 전달된다.
    public enum ForceLogoutReason: String, Sendable {
        /// 재발급 자체가 401/404로 실패.
        case refreshFailed = "refresh_failed"
        /// 재발급 성공, 재시도도 또 401.
        case retryFailed = "retry_failed"
    }

    private let tokenStorage: any TokenStorage
    private let tokenReissuer: any TokenReissuer
    private let notificationCenter: NotificationCenter
    private var isRefreshing = false
    private var pendingCompletion: [(Outcome) -> Void] = []
    private var hasNotifiedForceLogout = false
    // 강제 로그아웃/새 로그인마다 증가하는 세대. 늦게 성공한 재발급이 죽은 세션을 되살리지 못하게 막는다.
    private var generation = 0
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
        let result: (shouldRefresh: Bool, generation: Int) = lock.withLock {
            pendingCompletion.append(completion)
            guard !isRefreshing else { return (false, generation) }
            isRefreshing = true
            return (true, generation)
        }

        guard result.shouldRefresh else { return }
        let myGeneration = result.generation

        Task {
            do {
                guard let refreshToken = tokenStorage.refreshToken else {
                    throw NetworkError.unauthorized
                }
                let newTokens = try await tokenReissuer.reissue(refreshToken: refreshToken)
                let isStale = lock.withLock { generation != myGeneration }
                guard !isStale else {
                    // 이 사이클이 끝나기 전에 다른 경로(retryCount>0 등)가 이미 세션을 죽였다 — 되살리지 않는다.
                    resolveAll(.failed(.unauthorized))
                    return
                }
                tokenStorage.saveTokens(
                    accessToken: newTokens.accessToken,
                    refreshToken: newTokens.refreshToken
                )
                resolveAll(.retry)
            } catch {
                // TokenReissuer 구현체는 항상 NetworkError를 던지므로 이 캐스팅은 사실상 항상 성공한다.
                let networkError = error as? NetworkError ?? .unknown(error)
                resolveAll(.failed(networkError))
            }
        }
    }

    private func resolveAll(_ outcome: Outcome) {
        // completion 재진입 시 데드락 방지 — 큐만 비우고 락 밖에서 실행한다.
        // 세대 증가도 completion 실행 전에 확정 — 재진입한 refresh()가 새 세대를 보게 한다.
        let (completions, shouldNotify) = lock.withLock {
            let completions = pendingCompletion
            pendingCompletion.removeAll()
            isRefreshing = false

            var shouldNotify = false
            switch outcome {
            case .retry:
                // 세션이 다시 살아났으니, 이후에 또 끊기면 강제 로그아웃을 다시 통지할 수 있어야 한다.
                hasNotifiedForceLogout = false
            case .failed(let networkError) where networkError.requiresForceLogout:
                if !hasNotifiedForceLogout {
                    hasNotifiedForceLogout = true
                    generation += 1
                    shouldNotify = true
                }
            case .failed:
                break
            }
            return (completions, shouldNotify)
        }
        completions.forEach { $0(outcome) }
        if shouldNotify {
            postForceLogoutNotification(reason: .refreshFailed)
        }
    }

    /// retryCount 초과 등 single-flight 경로를 거치지 않는 확정적 실패도 같은 알림 채널을 쓰도록 노출한다.
    /// 여러 경로에서 동시에 호출돼도(예: 재시도한 여러 요청이 동시에 또 401을 받는 경우) 세션당 1회만 통지한다.
    public func notifyForceLogout(reason: ForceLogoutReason) {
        let shouldNotify = lock.withLock {
            guard !hasNotifiedForceLogout else { return false }
            hasNotifiedForceLogout = true
            generation += 1
            return true
        }
        guard shouldNotify else { return }
        postForceLogoutNotification(reason: reason)
    }

    private func postForceLogoutNotification(reason: ForceLogoutReason) {
        // NotificationCenter.post는 스레드 세이프해서 액터 격리 없이 바로 호출한다.
        notificationCenter.post(
            name: .forceLogout,
            object: nil,
            userInfo: [ForceLogoutUserInfoKey.reason: reason.rawValue]
        )
    }

    /// 새 로그인 완료 시 호출 — 이전 세션의 강제 로그아웃 통지 기록을 지우고 세대를 올린다.
    public func sessionDidStart() {
        lock.withLock {
            hasNotifiedForceLogout = false
            generation += 1
        }
    }
}

public extension Notification.Name {
    static let forceLogout = Notification.Name("ChungBazi.forceLogout")
}

/// `.forceLogout` 알림의 `userInfo` 키.
public enum ForceLogoutUserInfoKey {
    public static let reason = "reason"
}
