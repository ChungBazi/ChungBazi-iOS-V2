// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct LoginView: View {

    // MARK: - Properties

    private static let bottomInsetRatio: CGFloat = 0.0985

    let store: StoreOf<LoginFeature>

    /// 소셜 로그인 버튼 글자 크기. 고정 시스템 폰트라 Dynamic Type에 맞춰 스케일한다.
    @ScaledMetric(relativeTo: .body) private var loginFontSize: CGFloat = 15

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
            .accessibilityHidden(true)
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
                    .font(.system(size: loginFontSize, weight: .medium))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 45)
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
