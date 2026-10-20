// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct LinkedAccountsClient: Sendable {
    /// 현재 로그인된 소셜 계정 정보를 얻기 위해 내 프로필을 조회한다.
    public var getProfile: @Sendable () async throws -> UserProfile
}

extension LinkedAccountsClient: TestDependencyKey {
    public static let testValue = LinkedAccountsClient()

    public static let previewValue = LinkedAccountsClient(
        getProfile: { UserProfile(nickname: "바지", email: "chungbazi@kakao.com", socialType: .kakao) }
    )
}

extension DependencyValues {
    public var linkedAccountsClient: LinkedAccountsClient {
        get { self[LinkedAccountsClient.self] }
        set { self[LinkedAccountsClient.self] = newValue }
    }
}
