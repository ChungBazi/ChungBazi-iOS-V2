// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct OnboardingView: View {

    // MARK: - Properties

    let store: StoreOf<OnboardingFeature>

    // MARK: - Init

    public init(store: StoreOf<OnboardingFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
    }
}

// MARK: - Subviews

extension OnboardingView {

    private var content: some View {
        VStack(spacing: 16) {
            Text("온보딩")
                .font(.title2)

            Button("완료") {
                store.send(.didTapCompleteButton)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingView(
        store: Store(initialState: .init()) {
            OnboardingFeature()
        }
    )
}
