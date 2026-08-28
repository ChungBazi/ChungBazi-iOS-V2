// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct NicknameEditView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<NicknameEditFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<NicknameEditFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .baziNavigationBar_backWithTitle("닉네임 수정") {
                dismiss()
            }
            .baziToast(isPresented: $store.isSuccessToastPresented, message: "닉네임이 수정되었어요")
    }
}

// MARK: - Subviews

extension NicknameEditView {

    private var content: some View {
        VStack(spacing: 36) {
            titleText
            inputField
            Spacer()
            saveButton
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .baziBackground(.bgWhite)
    }

    private var titleText: some View {
        Text("어떤 이름으로 변경할까요?")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private var inputField: some View {
        BZInputField(
            text: $store.draftNickname,
            placeholder: "닉네임을 입력해주세요",
            currentNickname: store.currentNickname
        )
    }

    private var saveButton: some View {
        BZButton("저장하기") {
            store.send(.didTapSaveButton)
        }
        .baziToastAnchor()
        .disabled(!store.isSaveEnabled || store.isSaving)
        .padding(.bottom, 5)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        NicknameEditView(
            store: Store(initialState: .init(currentNickname: "민재")) {
                NicknameEditFeature()
            }
        )
    }
}
