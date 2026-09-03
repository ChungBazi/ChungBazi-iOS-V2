// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
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
            .baziToast(errorMessage: $store.errorToast)
    }
}

// MARK: - Subviews

extension NicknameSetupView {

    private var content: some View {
        VStack(spacing: 36) {
            titleText
                .padding(.top, 35)
            inputField
            Spacer()
            confirmButton
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 20)
        .baziBackground(.bgWhite)
    }

    private var titleText: some View {
        Text("어떤 이름으로 불러드릴까요?")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
            .multilineTextAlignment(.center)
    }

    private var inputField: some View {
        BZInputField(text: $store.nickname, placeholder: "닉네임을 입력해주세요")
    }

    private var confirmButton: some View {
        BZButton("완료하기") {
            store.send(.didTapConfirmButton)
        }
        .disabled(!store.isNicknameValid || store.isSaving)
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
