// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziNetwork
import BaziPresentation
import BaziStorage

extension SessionClient: @retroactive DependencyKey {

    public static let liveValue: SessionClient = {
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        let resetSessionUseCase: any ResetSessionUseCase = ResetSessionUseCaseImpl(
            tokenStorage: KeychainTokenStorage(),
            sessionStateRepository: sessionStateRepository
        )
        let userNameUseCase: any UserNameUseCase = UserNameUseCaseImpl(
            sessionStateRepository: sessionStateRepository
        )

        return SessionClient(
            forceLogoutEvents: {
                AsyncStream { continuation in
                    // 옵저버 토큰은 제거용으로만 쓰고 NotificationCenter는 스레드 안전 → 캡처 안전.
                    nonisolated(unsafe) let observer = NotificationCenter.default.addObserver(
                        forName: .forceLogout,
                        object: nil,
                        queue: nil
                    ) { _ in
                        continuation.yield(())
                    }
                    continuation.onTermination = { _ in
                        NotificationCenter.default.removeObserver(observer)
                    }
                }
            },
            resetSession: { resetSessionUseCase.execute() },
            userName: { userNameUseCase.get() }
        )
    }()
}
