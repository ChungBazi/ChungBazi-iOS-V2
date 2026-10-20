// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziCore
import BaziDomain
import BaziPresentation

extension AppConfigClient: @retroactive DependencyKey {

    public static let liveValue: AppConfigClient = {
        let useCase: any AppConfigUseCase = AppConfigUseCaseImpl(
            service: AppDependencies.remoteConfigService,
            currentVersion: AppInfo.version
        )
        return AppConfigClient(
            evaluateGate: { await useCase.evaluateGate() },
            isUpdateAvailable: { useCase.isUpdateAvailable() }
        )
    }()
}
