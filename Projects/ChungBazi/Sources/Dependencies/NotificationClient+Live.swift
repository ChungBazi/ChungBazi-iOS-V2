// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension NotificationClient: @retroactive DependencyKey {

    public static let liveValue: NotificationClient = {
        let repository: any NotificationRepository = NotificationRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let fetchUseCase: any FetchNotificationsUseCase = FetchNotificationsUseCaseImpl(notificationRepository: repository)
        let deleteUseCase: any DeleteNotificationUseCase = DeleteNotificationUseCaseImpl(notificationRepository: repository)

        return NotificationClient(
            fetch: { category, cursor, size in
                let page = try await fetchUseCase.execute(category: category, cursor: cursor, size: size)
                return NotificationPageVO(page)
            },
            delete: { id in try await deleteUseCase.execute(notificationId: id) },
            deleteAll: { try await deleteUseCase.executeAll() }
        )
    }()
}
