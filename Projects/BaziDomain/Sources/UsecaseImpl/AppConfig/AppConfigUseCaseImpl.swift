// Copyright © 2026 ChungBazi. All rights reserved.

import BaziCore

public struct AppConfigUseCaseImpl: AppConfigUseCase {

    private let service: RemoteConfigService
    private let currentVersion: String

    public init(service: RemoteConfigService, currentVersion: String) {
        self.service = service
        self.currentVersion = currentVersion
    }

    public func evaluateGate() async -> AppLaunchGate {
        try? await service.fetchAndActivate()
        let config = service.currentConfig()
        if config.isServerCheck {
            return .maintenance(message: config.serverCheckMessage)
        }
        if let current = SemanticVersion(currentVersion),
           let minimum = SemanticVersion(config.minimumVersion),
           current < minimum {
            return .forceUpdate
        }
        return .normal
    }

    public func isUpdateAvailable() -> Bool {
        let config = service.currentConfig()
        guard let current = SemanticVersion(currentVersion),
              let latest = SemanticVersion(config.latestVersion) else {
            return false
        }
        return current < latest
    }
}
