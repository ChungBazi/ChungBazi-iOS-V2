// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct HomeView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<HomeFeature>

    // MARK: - Init

    public init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            content
                .task { store.send(.onAppear) }
        } destination: { store in
            switch store.case {
            case .detail(let store):
                PlaceholderDetailView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension HomeView {

    private var content: some View {
        VStack(spacing: 16) {
            Text("홈")
                .font(.title)

            Button("정책 상세 보기") {
                store.send(.didTapPlaceholderRow)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        store: Store(initialState: .init()) {
            HomeFeature()
        }
    )
}
