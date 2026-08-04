// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension SplashClient: @retroactive DependencyKey {

    public static let liveValue: SplashClient = {
        let checkSessionUseCase: any CheckSessionUseCase = CheckSessionUseCaseImpl(
            tokenStorage: KeychainTokenStorage(),
            sessionStateRepository: SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        )

        return SplashClient(checkSession: { checkSessionUseCase.execute() })
    }()
}
