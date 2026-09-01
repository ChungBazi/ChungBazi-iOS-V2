// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct ProfileInfoEditView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<ProfileInfoEditFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<ProfileInfoEditFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .baziNavigationBar_backWithTitle("내 정보 수정") {
                dismiss()
            }
            .baziAlert(
                isPresented: Binding(
                    get: { store.activeAlert == .logout },
                    set: { if !$0 { store.send(.didCancelLogout) } }
                ),
                title: "로그아웃 할까요?",
                message: "현재 계정에서 로그아웃됩니다.\n다시 이용하려면 로그인해 주세요.",
                confirmTitle: "로그아웃",
                onConfirm: { store.send(.didConfirmLogout) }
            )
            .baziAlert(
                isPresented: Binding(
                    get: { store.activeAlert == .withdraw },
                    set: { if !$0 { store.send(.didCancelWithdraw) } }
                ),
                title: "탈퇴를 진행할까요?",
                message: "확인을 누르면 탈퇴 절차를\n진행하는 화면으로 이동해요",
                confirmTitle: "확인",
                onConfirm: { store.send(.didConfirmWithdraw) }
            )
            .alert(
                "로그아웃에 실패했어요",
                isPresented: Binding(
                    get: { store.activeAlert == .error },
                    set: { isPresented in
                        if !isPresented { store.send(.didDismissError) }
                    }
                )
            ) {
                Button("확인") { store.send(.didDismissError) }
            } message: {
                Text("잠시 후 다시 시도해 주세요.")
            }
    }
}

// MARK: - Subviews

extension ProfileInfoEditView {

    private var content: some View {
        VStack(spacing: 0) {
            ProfileRow("닉네임 수정") { store.send(.didTapNicknameEdit) }
            ProfileRow("로그인된 소셜 계정") { store.send(.didTapLinkedAccounts) }
            ProfileRow("로그아웃", showsChevron: false) { store.send(.didTapLogout) }
            ProfileRow("탈퇴하기", showsChevron: false) { store.send(.didTapWithdraw) }
            Spacer()
        }
        .padding(.horizontal, 20)
        .baziBackground(.bgWhite)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileInfoEditView(
            store: Store(initialState: .init()) {
                ProfileInfoEditFeature()
            }
        )
    }
}
