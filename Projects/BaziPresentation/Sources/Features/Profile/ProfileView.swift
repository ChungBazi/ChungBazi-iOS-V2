// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct ProfileView: View {

    // MARK: - Properties

    let store: StoreOf<ProfileFeature>

    // MARK: - Init

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
    }
}

// MARK: - Subviews

extension ProfileView {

    private var content: some View {
        Text("프로필")
    }
}

// MARK: - Preview

#Preview {
    ProfileView(
        store: Store(initialState: .init()) {
            ProfileFeature()
        }
    )
}
