// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension NotificationSettingClient: @retroactive DependencyKey {

    public static let liveValue: NotificationSettingClient = {
        let repository: any NotificationSettingRepository = NotificationSettingRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let getUseCase: any GetNotificationSettingsUseCase = GetNotificationSettingsUseCaseImpl(repository: repository)
        let updateUseCase: any UpdateNotificationSettingsUseCase = UpdateNotificationSettingsUseCaseImpl(repository: repository)

        return NotificationSettingClient(
            getSettings: { try await getUseCase.execute() },
            updateSettings: { try await updateUseCase.execute($0) }
        )
    }()
}
