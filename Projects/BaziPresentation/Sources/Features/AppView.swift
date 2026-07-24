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
            .task { store.send(.onAppear) }
    }
}

// MARK: - Subviews

extension AppView {

    @ViewBuilder
    private var content: some View {
        switch store.state {
        case .splash:
            ProgressView()

        case .login:
            if let store = store.scope(state: \.login, action: \.login) {
                LoginView(store: store)
            }

        case .nicknameSetup:
            if let store = store.scope(state: \.nicknameSetup, action: \.nicknameSetup) {
                NicknameSetupView(store: store)
            }

        case .onboarding:
            if let store = store.scope(state: \.onboarding, action: \.onboarding) {
                OnboardingView(store: store)
            }

        case .main:
            if let store = store.scope(state: \.main, action: \.main) {
                MainView(store: store)
            }
        }
    }
}
