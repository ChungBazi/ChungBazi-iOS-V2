// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziCore
import BaziDomain
import BaziNetwork

public struct AuthRepositoryImpl: AuthRepository {

    private let networkProvider: NetworkProvider
    private let tokenStorage: TokenStorage

    public init(networkProvider: NetworkProvider, tokenStorage: TokenStorage) {
        self.networkProvider = networkProvider
        self.tokenStorage = tokenStorage
    }

    public func kakaoLogin(accessToken: String, fcmToken: String) async throws -> AccountStatus {
        let dto: LoginResponseDTO = try await networkProvider.request(
            AuthAPI.kakaoLogin(body: KakaoLoginRequestDTO(accessToken: accessToken, fcmToken: fcmToken))
        )
        tokenStorage.saveTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
        return dto.toDomain()
    }

    public func appleLogin(idToken: String, name: String, fcmToken: String) async throws -> AccountStatus {
        let dto: LoginResponseDTO = try await networkProvider.request(
            AuthAPI.appleLogin(body: AppleLoginRequestDTO(idToken: idToken, name: name, fcmToken: fcmToken))
        )
        tokenStorage.saveTokens(accessToken: dto.accessToken, refreshToken: dto.refreshToken)
        return dto.toDomain()
    }
}
