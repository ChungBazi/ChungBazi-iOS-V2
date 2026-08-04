// Copyright © 2026 ChungBazi. All rights reserved.

import AuthenticationServices
import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct LoginView: View {

    // MARK: - Properties

    private static let bottomInsetRatio: CGFloat = 0.0985

    let store: StoreOf<LoginFeature>

    // MARK: - Init

    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
    }
}

// MARK: - Subviews

extension LoginView {

    private var content: some View {
        GeometryReader { proxy in
            ZStack {
                Color.bazi(.primary)
                background
                VStack {
                    Spacer()
                    buttonStack
                        .padding(.horizontal, 37.5)
                        .padding(.bottom, proxy.size.height * Self.bottomInsetRatio)
                }
            }
        }
        .ignoresSafeArea()
    }

    private var background: some View {
        Image.bazi(.loginBackground)
            .resizable()
            .scaledToFit()
    }

    private var buttonStack: some View {
        VStack(spacing: 12) {
            kakaoLoginButton
            appleLoginButton
        }
    }

    private var kakaoLoginButton: some View {
        Button {
            store.send(.didTapKakaoLoginButton)
        } label: {
            HStack(spacing: 8) {
                Image.bazi(.kakaoIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18)

                Text("카카오로 로그인")
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(Color.grayBlack)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(Color.kakao)
            .baziRadius(.small)
        }
    }

    private var appleLoginButton: some View {
        SignInWithAppleButton(.signIn) { request in
            request.requestedScopes = [.fullName, .email]
        } onCompletion: { result in
            guard
                case .success(let authorization) = result,
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let identityTokenData = credential.identityToken,
                let idToken = String(data: identityTokenData, encoding: .utf8)
            else { return }

            // fullName은 최초 로그인 시에만 내려온다.
            let name = credential.fullName.flatMap {
                PersonNameComponentsFormatter().string(from: $0)
            }
            store.send(.didTapAppleLoginButton(idToken: idToken, name: name?.isEmpty == false ? name : nil))
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 45)
        .baziRadius(.small)
    }
}

// MARK: - Preview

#Preview {
    LoginView(
        store: Store(initialState: .init()) {
            LoginFeature()
        }
    )
}
