// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension WithdrawClient: @retroactive DependencyKey {

    public static let liveValue: WithdrawClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        let withdrawUseCase: any WithdrawUseCase = WithdrawUseCaseImpl(
            userRepository: userRepository,
            kakaoAuthService: KakaoAuthServiceImpl(),
            sessionStateRepository: sessionStateRepository
        )

        return WithdrawClient(
            withdraw: { request in
                try await withdrawUseCase.execute(request)
            }
        )
    }()
}
