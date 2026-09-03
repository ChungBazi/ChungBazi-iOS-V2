// Copyright © 2026 ChungBazi. All rights reserved.

/// RemoteConfig에서 내려오는 앱 설정 값.
public struct AppConfig: Equatable, Sendable {
    public let isServerCheck: Bool
    public let minimumVersion: String
    public let latestVersion: String
    public let serverCheckMessage: String

    public init(isServerCheck: Bool, minimumVersion: String, latestVersion: String, serverCheckMessage: String) {
        self.isServerCheck = isServerCheck
        self.minimumVersion = minimumVersion
        self.latestVersion = latestVersion
        self.serverCheckMessage = serverCheckMessage
    }
}
