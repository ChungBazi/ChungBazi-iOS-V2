// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct SplashView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<SplashFeature>

    // MARK: - Init

    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
    }
}

// MARK: - Subviews

extension SplashView {

    private var content: some View {
        ZStack {
            Color.bazi(.primary)
            phaseContent
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch store.phase {
        case .tagline:
            taglineText

        case .logo:
            logoImage
        }
    }

    private var taglineText: some View {
        Text("청년정책 바로 지금")
            .baziFont(.head28B)
            .foregroundStyle(Color.grayWhite)
    }

    private var logoImage: some View {
        Image.bazi(.appLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 100)
            .foregroundStyle(Color.grayWhite)
    }
}

// MARK: - Preview

#Preview {
    SplashView(
        store: Store(initialState: .init()) {
            SplashFeature()
        }
    )
}
