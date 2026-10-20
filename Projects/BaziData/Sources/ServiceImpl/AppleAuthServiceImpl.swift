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
        try await withTaskCancellationHandler {
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
        } onCancel: {
            DispatchQueue.main.async {
                self.authController?.cancel()
                self.authController = nil
                self.finish(.failure(CancellationError()))
            }
        }
    }

    /// continuation을 한 번만 재개하고 정리한다. (성공/실패/취소 공통, 항상 main에서 호출)
    private func finish(_ result: Result<AppleCredential, Error>) {
        guard let continuation else { return }
        self.continuation = nil
        continuation.resume(with: result)
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthServiceImpl: ASAuthorizationControllerDelegate {

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        authController = nil
        guard
            let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let identityTokenData = credential.identityToken,
            let idToken = String(data: identityTokenData, encoding: .utf8)
        else {
            finish(.failure(UseCaseError.unknown))
            return
        }

        // fullName은 최초 로그인 시에만 내려온다.
        let name = credential.fullName.flatMap {
            PersonNameComponentsFormatter().string(from: $0)
        }
        finish(.success(AppleCredential(idToken: idToken, name: name?.isEmpty == false ? name : nil)))
    }

    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        authController = nil
        // 사용자 취소는 오류가 아니라 취소로 매핑한다. 그 외는 그대로 던져 상위에서 매핑.
        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            finish(.failure(UseCaseError.cancelled))
        } else {
            finish(.failure(error))
        }
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
