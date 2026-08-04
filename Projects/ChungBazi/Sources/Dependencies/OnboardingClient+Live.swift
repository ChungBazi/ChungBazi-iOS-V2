// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension OnboardingClient: @retroactive DependencyKey {

    public static let liveValue: OnboardingClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let regionRepository: any RegionRepository = RegionRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        
        let submitOnboardingUseCase: any SubmitOnboardingUseCase = SubmitOnboardingUseCaseImpl(
            userRepository: userRepository,
            sessionStateRepository: sessionStateRepository
        )
        let fetchSidoListUseCase: any FetchSidoListUseCase = FetchSidoListUseCaseImpl(regionRepository: regionRepository)
        let fetchSigunguListUseCase: any FetchSigunguListUseCase = FetchSigunguListUseCaseImpl(regionRepository: regionRepository)
        
        return OnboardingClient(
            fetchSidoList: { try await fetchSidoListUseCase.execute() },
            fetchSigunguList: { sidoCode in try await fetchSigunguListUseCase.execute(sidoCode: sidoCode) },
            submitOnboarding: { info in try await submitOnboardingUseCase.execute(info) }
        )
    }()
}
