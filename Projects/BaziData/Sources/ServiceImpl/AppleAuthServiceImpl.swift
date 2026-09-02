// Copyright © 2026 ChungBazi. All rights reserved.

import AuthenticationServices
import Foundation
import UIKit

import BaziDomain

/// 애플 로그인(AuthenticationServices)을 수행한다. ASAuthorizationController의 델리게이트 콜백을 async continuation으로 감싸 idToken/name을 반환한다.
/// (카카오와 달리 델리게이트 객체가 필요해 struct가 아닌 class + @unchecked Sendable)
public final class AppleAuthServiceImpl: NSObject, AppleAuthService, @unchecked Sendable {

    private var continuation: CheckedContinuation<AppleCredential, Error>?
    /// 인증이 끝날 때까지 컨트롤러가 해제되지 않도록 강한 참조를 유지한다.
    private var authController: ASAuthorizationController?

    public override init() {
        super.init()
    }

    public func login() async throws -> AppleCredential {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                self.continuation = continuation
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = self
                controller.presentationContextProvider = self
                self.authController = controller
                controller.performRequests()
            }
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthServiceImpl: ASAuthorizationControllerDelegate {

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        defer { authController = nil }
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityTokenData = credential.identityToken,
            let idToken = String(data: identityTokenData, encoding: .utf8)
        else {
            continuation?.resume(throwing: UseCaseError.unknown("애플 로그인 응답이 비어 있습니다."))
            continuation = nil
            return
        }

        // fullName은 최초 로그인 시에만 내려온다.
        let name = credential.fullName.flatMap {
            PersonNameComponentsFormatter().string(from: $0)
        }
        continuation?.resume(returning: AppleCredential(idToken: idToken, name: name?.isEmpty == false ? name : nil))
        continuation = nil
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        authController = nil
        // 사용자 취소를 포함한 실패는 그대로 던진다. (상위에서 UseCaseError로 매핑)
        continuation?.resume(throwing: error)
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthServiceImpl: ASAuthorizationControllerPresentationContextProviding {

    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow) ?? ASPresentationAnchor()
        }
    }
}
