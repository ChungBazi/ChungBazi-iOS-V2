// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@DependencyClient
public struct SplashClient: Sendable {
    public var checkSession: @Sendable () async -> (hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool) = {
        (false, false, false)
    }
}

extension SplashClient: TestDependencyKey {
    public static let testValue = SplashClient()

    public static let previewValue = SplashClient(
        checkSession: { (true, true, true) }
    )
}

extension DependencyValues {
    public var splashClient: SplashClient {
        get { self[SplashClient.self] }
        set { self[SplashClient.self] = newValue }
    }
}
