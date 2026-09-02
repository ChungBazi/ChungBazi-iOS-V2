// Copyright © 2026 ChungBazi. All rights reserved.

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
        .disabled(store.isLoading)
    }

    private var kakaoLoginButton: some View {
        socialLoginButton(
            icon: .bazi(.kakaoIcon),
            title: "카카오로 로그인",
            foreground: Color.grayBlack,
            background: Color.kakao
        ) {
            store.send(.didTapKakaoLoginButton)
        }
    }

    private var appleLoginButton: some View {
        socialLoginButton(
            icon: .bazi(.appleLogo),
            iconWidth: 27,
            iconBlendMode: .screen,
            iconSpacing: 1,
            title: "Apple로 로그인",
            foreground: Color.grayWhite,
            background: Color.grayBlack
        ) {
            store.send(.didTapAppleLoginButton)
        }
    }

    private func socialLoginButton(
        icon: Image,
        iconWidth: CGFloat = 17,
        iconBlendMode: BlendMode = .normal,
        iconSpacing: CGFloat = 8,
        title: String,
        foreground: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: iconSpacing) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: iconWidth)
                    .blendMode(iconBlendMode)

                Text(title)
                    .font(.system(size: 15, weight: .medium))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 45)
            .background(background)
            .baziRadius(.small)
        }
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
