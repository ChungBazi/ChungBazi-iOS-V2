// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct MyPolicyView: View {

    // MARK: - Properties

    let store: StoreOf<MyPolicyFeature>

    // MARK: - Init

    public init(store: StoreOf<MyPolicyFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
    }
}

// MARK: - Subviews

extension MyPolicyView {

    private var content: some View {
        Text("내 정책")
    }
}

// MARK: - Preview

#Preview {
    MyPolicyView(
        store: Store(initialState: .init()) {
            MyPolicyFeature()
        }
    )
}
