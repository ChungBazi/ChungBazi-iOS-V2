// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension HomeClient: @retroactive DependencyKey {

    public static let liveValue: HomeClient = {
        let homeRepository = AppDependencies.homeRepository
        let sessionStateRepository: any SessionStateRepository = SessionStateRepositoryImpl(storage: UserDefaultsStorage())
        let fetchHomeFeedUseCase: any FetchHomeFeedUseCase = FetchHomeFeedUseCaseImpl(homeRepository: homeRepository)
        let userNameUseCase: any UserNameUseCase = UserNameUseCaseImpl(sessionStateRepository: sessionStateRepository)

        return HomeClient(
            fetchHomeFeed: { forceRefresh in
                let feed = try await fetchHomeFeedUseCase.execute(forceRefresh: forceRefresh)
                // 응답에 담긴 닉네임을 로컬에 저장해 로그아웃/탈퇴 전까지 재사용한다.
                userNameUseCase.save(feed.userName)
                return HomeFeedVO(feed)
            }
        )
    }()
}
