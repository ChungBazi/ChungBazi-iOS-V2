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
        let logoutUseCase: any LogoutUseCase = LogoutUseCaseImpl(
            authRepository: AuthRepositoryImpl(
                networkProvider: AppDependencies.networkProvider,
                tokenStorage: KeychainTokenStorage()
            )
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
            userName: { userNameUseCase.get() },
            displayName: { userNameUseCase.get() ?? "회원" },
            logout: {
                try await logoutUseCase.execute()  // 서버 로그아웃 (성공해야 진행)
                resetSessionUseCase.execute()       // 로컬 토큰/세션 초기화
            }
        )
    }()
}
