// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct AuthClient: Sendable {
    public var loginWithKakao: @Sendable () async throws -> AccountStatus
    public var loginWithApple: @Sendable (_ idToken: String, _ name: String?) async throws -> AccountStatus
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient()

    public static let previewValue = AuthClient(
        loginWithKakao: {
            AccountStatus(hasNickname: false, hasCompletedOnboarding: false)
        },
        loginWithApple: { _, _ in
            AccountStatus(hasNickname: false, hasCompletedOnboarding: false)
        }
    )
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
