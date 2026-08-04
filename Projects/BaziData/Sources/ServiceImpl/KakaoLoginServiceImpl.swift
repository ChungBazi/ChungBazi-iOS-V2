// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import KakaoSDKAuth
import KakaoSDKUser

public struct KakaoLoginServiceImpl: KakaoLoginService {

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
}
