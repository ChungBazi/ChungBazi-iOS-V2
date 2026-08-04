// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct AuthClient: Sendable {
    public var loginWithKakao: @Sendable () async throws -> AuthSessionEntity
    public var loginWithApple: @Sendable (_ idToken: String, _ name: String?) async throws -> AuthSessionEntity
}

extension AuthClient: TestDependencyKey {
    public static let testValue = AuthClient()

    public static let previewValue = AuthClient(
        loginWithKakao: {
            AuthSessionEntity(
                accessToken: "preview-access-token",
                refreshToken: "preview-refresh-token",
                email: "preview@chungbazi.com",
                socialType: .kakao,
                hasNickname: false,
                hasCompletedOnboarding: false
            )
        },
        loginWithApple: { _, _ in
            AuthSessionEntity(
                accessToken: "preview-access-token",
                refreshToken: "preview-refresh-token",
                email: "preview@chungbazi.com",
                socialType: .apple,
                hasNickname: false,
                hasCompletedOnboarding: false
            )
        }
    )
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
