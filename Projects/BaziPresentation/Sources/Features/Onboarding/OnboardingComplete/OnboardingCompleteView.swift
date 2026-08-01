// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct OnboardingCompleteView: View {

    // MARK: - Properties
    let store: StoreOf<OnboardingCompleteFeature>

    // MARK: - Init

    public init(store: StoreOf<OnboardingCompleteFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Subviews

extension OnboardingCompleteView {

    private var content: some View {
        // TODO: 온보딩 정보 POST 응답으로 닉네임이 내려오면 "{닉네임}님에게 딱 맞는"으로 교체.
        OnboardingBackgroundLayout(
            background: .endOnboardingBackground,
            title: "회원님에게 딱 맞는\n정책을 찾았어요!"
        ) {
            confirmButton
        }
    }

    private var confirmButton: some View {
        BZButton("홈에서 맞춤 정책 확인하기") {
            store.send(.didTapConfirmButton)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingCompleteView(
        store: Store(initialState: .init()) {
            OnboardingCompleteFeature()
        }
    )
}
