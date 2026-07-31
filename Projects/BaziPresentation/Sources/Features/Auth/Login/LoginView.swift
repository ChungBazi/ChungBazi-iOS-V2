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
        SignInWithAppleButton(.signIn) { _ in
            // TODO: authClient가 준비되면 실제 request 구성으로 교체.
        } onCompletion: { result in
            switch result {
            case .success:
                store.send(.didTapAppleLoginButton)
            case .failure:
                break
            }
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
