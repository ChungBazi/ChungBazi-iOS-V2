// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension SplashClient: @retroactive DependencyKey {

    public static let liveValue: SplashClient = {
        let tokenStorage = KeychainTokenStorage()
        let authRepository: any AuthRepository = AuthRepositoryImpl(
            networkProvider: AppDependencies.networkProvider,
            tokenStorage: tokenStorage
        )
        let checkSessionUseCase: any CheckSessionUseCase = CheckSessionUseCaseImpl(
            tokenStorage: tokenStorage,
            sessionStateRepository: SessionStateRepositoryImpl(storage: UserDefaultsStorage()),
            authRepository: authRepository
        )

        return SplashClient(checkSession: { await checkSessionUseCase.execute() })
    }()
}
