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

        // 안읽음 배지는 홈 aggregate 캐시와 무관하게 매번 새로 조회해야 하므로 Notification 도메인 UseCase를 그대로 가져온다.
        let notificationRepository: any NotificationRepository = NotificationRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let fetchUnreadStatusUseCase: any FetchUnreadNotificationStatusUseCase = FetchUnreadNotificationStatusUseCaseImpl(
            notificationRepository: notificationRepository
        )

        return HomeClient(
            fetchHomeFeed: { forceRefresh in
                let feed = try await fetchHomeFeedUseCase.execute(forceRefresh: forceRefresh)
                // 응답에 담긴 닉네임을 로컬에 저장해 로그아웃/탈퇴 전까지 재사용한다.
                userNameUseCase.save(feed.userName)
                return HomeFeedVO(feed)
            },
            fetchUnreadStatus: {
                try await fetchUnreadStatusUseCase.execute()
            }
        )
    }()
}
