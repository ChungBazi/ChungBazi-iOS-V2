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

    // 인증 필요한 /me를 1회 호출해 세션을 검증한다. 401(reissue까지 실패)만 무효로 확정하고,
    // 그 외(오프라인/타임아웃/서버오류)는 판정 불가로 남겨 상위에서 로컬 폴백하도록 한다.
    public func validateSession() async -> SessionValidity {
        let provider = networkProvider
        do {
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    let _: UserInfoResponseDTO = try await provider.request(UserAPI.getProfile)
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: 5_000_000_000) // 5s 타임아웃 (스플래시 무한대기 방지)
                    throw NetworkError.networkError(message: "세션 검증 시간 초과")
                }
                defer { group.cancelAll() }
                _ = try await group.next()
            }
            return .valid
        } catch NetworkError.unauthorized {
            return .invalid
        } catch {
            return .indeterminate
        }
    }

    public func logout() async throws {
        try await networkProvider.requestStatusCode(AuthAPI.logout)
    }
}
