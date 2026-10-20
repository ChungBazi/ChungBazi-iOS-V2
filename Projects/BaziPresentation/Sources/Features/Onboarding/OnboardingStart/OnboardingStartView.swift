// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct OnboardingStartView: View {

    // MARK: - Properties
    @Bindable var store: StoreOf<OnboardingStartFeature>

    // MARK: - Init

    public init(store: StoreOf<OnboardingStartFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            content
        } destination: { store in
            switch store.case {
            case .onboardingContainer(let store):
                OnboardingContainerView(store: store)

            case .onboardingComplete(let store):
                OnboardingCompleteView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension OnboardingStartView {
    
    private var content: some View {
        OnboardingBackgroundLayout(
            background: .startOnboardingBackground,
            title: "딱 맞는 정책을 찾기 위해\n몇 가지만 물어볼게요"
        ) {
            startButton
        }
    }

    private var startButton: some View {
        BZButton("네 좋아요!", type: .normal2) {
            store.send(.didTapStartButton)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingStartView(
        store: Store(initialState: .init()) {
            OnboardingStartFeature()
        }
    )
}
