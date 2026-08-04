// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct AuthRepositoryImpl: AuthRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func kakaoLogin(accessToken: String, fcmToken: String) async throws -> AuthSessionEntity {
        let dto: LoginResponseDTO = try await networkProvider.request(
            AuthAPI.kakaoLogin(body: KakaoLoginRequestDTO(accessToken: accessToken, fcmToken: fcmToken))
        )
        return try dto.toDomain()
    }

    public func appleLogin(idToken: String, name: String, fcmToken: String) async throws -> AuthSessionEntity {
        let dto: LoginResponseDTO = try await networkProvider.request(
            AuthAPI.appleLogin(body: AppleLoginRequestDTO(idToken: idToken, name: name, fcmToken: fcmToken))
        )
        return try dto.toDomain()
    }
}
