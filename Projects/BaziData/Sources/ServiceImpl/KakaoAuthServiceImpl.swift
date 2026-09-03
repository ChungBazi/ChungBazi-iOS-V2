// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

public struct KakaoAuthServiceImpl: KakaoAuthService {

    public init() {}

    public func login() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let completion: (OAuthToken?, Error?) -> Void = { token, error in
                if let error {
                    continuation.resume(throwing: Self.mapLoginError(error))
                } else if let token {
                    continuation.resume(returning: token.accessToken)
                } else {
                    continuation.resume(throwing: UseCaseError.unknown)
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

    /// 카카오 SDK 에러를 도메인 에러로 옮긴다. 사용자가 로그인 창을 닫으면 오류가 아니라 취소로 매핑한다.
    private static func mapLoginError(_ error: Error) -> UseCaseError {
        if let sdkError = error as? SdkError, case .ClientFailed(.Cancelled, _) = sdkError {
            return .cancelled
        }
        return .unknown
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
