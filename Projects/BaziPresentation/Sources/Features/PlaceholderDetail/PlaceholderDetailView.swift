// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import SwiftUI

import ComposableArchitecture

public struct PlaceholderDetailView: View {

    // MARK: - Properties

    let store: StoreOf<PlaceholderDetailFeature>

    // MARK: - Init

    public init(store: StoreOf<PlaceholderDetailFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
    }
}

// MARK: - Subviews

extension PlaceholderDetailView {

    private var content: some View {
        Text("정책 상세 #\(store.id.uuidString.prefix(8))")
    }
}

// MARK: - Preview

#Preview {
    PlaceholderDetailView(
        store: Store(initialState: .init(id: UUID())) {
            PlaceholderDetailFeature()
        }
    )
}
