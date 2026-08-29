// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension NicknameClient: @retroactive DependencyKey {

    public static let liveValue: NicknameClient = {
        let userRepository: any UserRepository = UserRepositoryImpl(networkProvider: AppDependencies.networkProvider)
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        let userNameUseCase: any UserNameUseCase = UserNameUseCaseImpl(sessionStateRepository: sessionStateRepository)
        let setNicknameUseCase: any SetNicknameUseCase = SetNicknameUseCaseImpl(
            userRepository: userRepository,
            sessionStateRepository: sessionStateRepository
        )

        return NicknameClient(
            setNickname: { name in
                try await setNicknameUseCase.execute(name: name)
                userNameUseCase.save(name)
            }
        )
    }()
}
