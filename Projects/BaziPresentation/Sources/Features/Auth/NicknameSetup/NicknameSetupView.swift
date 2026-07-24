// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct NicknameSetupView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<NicknameSetupFeature>

    // MARK: - Init

    public init(store: StoreOf<NicknameSetupFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
    }
}

// MARK: - Subviews

extension NicknameSetupView {

    private var content: some View {
        VStack(spacing: 16) {
            Text("닉네임을 설정해주세요")
                .font(.title2)

            TextField("닉네임", text: $store.nickname)
                .textFieldStyle(.roundedBorder)

            Button("확인") {
                store.send(.didTapConfirmButton)
            }
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    NicknameSetupView(
        store: Store(initialState: .init()) {
            NicknameSetupFeature()
        }
    )
}
