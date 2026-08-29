// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension LinkedAccountsClient: @retroactive DependencyKey {

    public static let liveValue: LinkedAccountsClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        let getProfileUseCase: any GetProfileUseCase = GetProfileUseCaseImpl(
            userRepository: userRepository,
            sessionStateRepository: sessionStateRepository
        )

        return LinkedAccountsClient(
            getProfile: { try await getProfileUseCase.execute() }
        )
    }()
}
