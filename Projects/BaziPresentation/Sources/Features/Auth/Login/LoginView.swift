// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct LoginView: View {

    // MARK: - Properties

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
        VStack(spacing: 16) {
            Text("ChungBazi")
                .font(.largeTitle)

            Button("로그인") {
                store.send(.didTapLoginButton)
            }
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
