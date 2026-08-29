// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import KakaoSDKAuth
import KakaoSDKUser

public struct KakaoAuthServiceImpl: KakaoAuthService {

    public init() {}

    public func login() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token.accessToken)
                } else {
                    continuation.resume(throwing: UseCaseError.unknown("카카오 로그인 응답이 비어 있습니다."))
                }
            }

            DispatchQueue.main.async {
                if UserApi.isKakaoTalkLoginAvailable() {
                    UserApi.shared.loginWithKakaoTalk(completion: completion)
                } else {
                    UserApi.shared.loginWithKakaoAccount(completion: completion)
                }
            }
        }
    }

    public func unlink() async throws {
        // 카카오로 로그인한 계정만 해제한다. 토큰이 없으면(애플 계정 등) no-op.
        guard AuthApi.hasToken() else { return }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.unlink { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
