// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziCore
import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension AuthClient: @retroactive DependencyKey {

    public static let liveValue: AuthClient = {
        let tokenStorage: TokenStorage = KeychainTokenStorage()
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())

        let authRepository: any AuthRepository = AuthRepositoryImpl(
            networkProvider: AppDependencies.networkProvider,
            tokenStorage: tokenStorage
        )
        let kakaoLoginService: any KakaoLoginService = KakaoLoginServiceImpl()

        let kakaoLoginUseCase: any KakaoLoginUseCase = KakaoLoginUseCaseImpl(
            kakaoLoginService: kakaoLoginService,
            authRepository: authRepository,
            pushTokenRepository: AppDependencies.pushTokenRepository,
            sessionStateRepository: sessionStateRepository
        )
        let appleLoginUseCase: any AppleLoginUseCase = AppleLoginUseCaseImpl(
            authRepository: authRepository,
            pushTokenRepository: AppDependencies.pushTokenRepository,
            sessionStateRepository: sessionStateRepository
        )

        return AuthClient(
            loginWithKakao: { try await kakaoLoginUseCase.execute() },
            loginWithApple: { idToken, name in try await appleLoginUseCase.execute(idToken: idToken, name: name) }
        )
    }()
}
