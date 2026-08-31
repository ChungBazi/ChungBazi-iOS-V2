// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct AppView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<AppFeature>

    // MARK: - Init

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            // 스플래시/로그인/온보딩/메인 루트 전환을 크로스페이드로 부드럽게 한다.
            .animation(.easeInOut(duration: 0.35), value: screenID)
            .task { await store.send(.task).finish() }
    }

    /// 현재 표시 중인 루트 화면 식별자. 값이 바뀔 때 전환 애니메이션을 트리거한다.
    private var screenID: Int {
        switch store.state {
        case .splash: return 0
        case .login: return 1
        case .nicknameSetup: return 2
        case .onboarding: return 3
        case .main: return 4
        }
    }
}

// MARK: - Subviews

extension AppView {

    @ViewBuilder
    private var content: some View {
        switch store.state {
        case .splash:
            if let store = store.scope(state: \.splash, action: \.splash) {
                SplashView(store: store)
                    .transition(.opacity)
            }

        case .login:
            if let store = store.scope(state: \.login, action: \.login) {
                LoginView(store: store)
                    .transition(.opacity)
            }

        case .nicknameSetup:
            if let store = store.scope(state: \.nicknameSetup, action: \.nicknameSetup) {
                NicknameSetupView(store: store)
                    .transition(.opacity)
            }

        case .onboarding:
            if let store = store.scope(state: \.onboarding, action: \.onboarding) {
                OnboardingStartView(store: store)
                    .transition(.opacity)
            }

        case .main:
            if let store = store.scope(state: \.main, action: \.main) {
                MainView(store: store)
                    .transition(.opacity)
            }
        }
    }
}
