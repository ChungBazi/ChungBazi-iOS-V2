// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension PolicyLikeClient: @retroactive DependencyKey {

    public static let liveValue: PolicyLikeClient = {
        let policyDetailRepository: any PolicyDetailRepository = PolicyDetailRepositoryImpl(
            networkProvider: AppDependencies.networkProvider,
            cache: AppDependencies.policyCache
        )
        let toggleLikeUseCase: any ToggleLikeUseCase = ToggleLikeUseCaseImpl(policyDetailRepository: policyDetailRepository)

        return PolicyLikeClient(
            setLike: { policyId, liked in
                try await toggleLikeUseCase.execute(policyId: policyId, liked: liked)
            }
        )
    }()
}
