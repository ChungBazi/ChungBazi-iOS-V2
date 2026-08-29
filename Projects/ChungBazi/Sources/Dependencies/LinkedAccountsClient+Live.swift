// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension LinkedAccountsClient: @retroactive DependencyKey {

    public static let liveValue: LinkedAccountsClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let getProfileUseCase: any GetProfileUseCase = GetProfileUseCaseImpl(userRepository: userRepository)

        return LinkedAccountsClient(
            getProfile: { try await getProfileUseCase.execute() }
        )
    }()
}
