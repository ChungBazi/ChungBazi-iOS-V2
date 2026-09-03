// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension OnboardingClient: @retroactive DependencyKey {

    public static let liveValue: OnboardingClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        
        let submitOnboardingUseCase: any SubmitOnboardingUseCase = SubmitOnboardingUseCaseImpl(
            userRepository: userRepository,
            sessionStateRepository: sessionStateRepository
        )
        let userNameUseCase: any UserNameUseCase = UserNameUseCaseImpl(
            sessionStateRepository: sessionStateRepository
        )
        // 지역 레포는 캐시를 정책맞춤조건 편집(policyProfileClient)과 공유하기 위해 AppDependencies의 것을 쓴다.
        let fetchSidoListUseCase: any FetchSidoListUseCase = FetchSidoListUseCaseImpl(regionRepository: AppDependencies.regionRepository)
        let fetchSigunguListUseCase: any FetchSigunguListUseCase = FetchSigunguListUseCaseImpl(regionRepository: AppDependencies.regionRepository)
        
        return OnboardingClient(
            fetchSidoList: { try await fetchSidoListUseCase.execute() },
            fetchSigunguList: { sidoCode in try await fetchSigunguListUseCase.execute(sidoCode: sidoCode) },
            submitOnboarding: { info in
                let nickname = try await submitOnboardingUseCase.execute(info)
                // 온보딩 응답으로 받은 닉네임을 로컬에 저장(홈 이전에도 재사용).
                userNameUseCase.save(nickname)
                return nickname
            }
        )
    }()
}
