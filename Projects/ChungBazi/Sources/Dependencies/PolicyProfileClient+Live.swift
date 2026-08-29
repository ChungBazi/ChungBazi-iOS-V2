// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension PolicyProfileClient: @retroactive DependencyKey {

    public static let liveValue: PolicyProfileClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let getUseCase: any GetPolicyProfileUseCase = GetPolicyProfileUseCaseImpl(userRepository: userRepository)
        let updateUseCase: any UpdatePolicyProfileUseCase = UpdatePolicyProfileUseCaseImpl(userRepository: userRepository)

        return PolicyProfileClient(
            getPolicyProfile: { try await getUseCase.execute() },
            updatePolicyProfile: { try await updateUseCase.execute($0) }
        )
    }()
}
