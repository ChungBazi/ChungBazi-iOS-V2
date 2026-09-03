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
        // 지역(시도/시군구)은 온보딩과 같은 캐시를 쓰도록 AppDependencies의 공유 레포로 조립한다.
        let fetchSidoListUseCase: any FetchSidoListUseCase = FetchSidoListUseCaseImpl(regionRepository: AppDependencies.regionRepository)
        let fetchSigunguListUseCase: any FetchSigunguListUseCase = FetchSigunguListUseCaseImpl(regionRepository: AppDependencies.regionRepository)

        return PolicyProfileClient(
            getPolicyProfile: { try await getUseCase.execute() },
            updatePolicyProfile: { try await updateUseCase.execute($0) },
            fetchSidoList: { try await fetchSidoListUseCase.execute() },
            fetchSigunguList: { sidoCode in try await fetchSigunguListUseCase.execute(sidoCode: sidoCode) }
        )
    }()
}
