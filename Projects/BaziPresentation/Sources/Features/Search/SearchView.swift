// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct SearchView: View {

    // MARK: - Properties

    let store: StoreOf<SearchFeature>

    // MARK: - Init

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
    }
}

// MARK: - Subviews

extension SearchView {

    private var content: some View {
        Text("검색")
    }
}

// MARK: - Preview

#Preview {
    SearchView(
        store: Store(initialState: .init()) {
            SearchFeature()
        }
    )
}
