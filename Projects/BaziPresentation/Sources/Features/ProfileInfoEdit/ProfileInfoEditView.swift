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
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("내 정보 수정") {
                dismiss()
            }
            .overlay {
                if store.isLogoutAlertPresented {
                    logoutAlertOverlay
                }
            }
    }
}

// MARK: - Subviews

extension ProfileInfoEditView {

    private var content: some View {
        VStack(spacing: 0) {
            row(title: "닉네임 수정", showsChevron: true) {
                store.send(.didTapNicknameEdit)
            }
            row(title: "로그인된 소셜 계정", showsChevron: true) {
                store.send(.didTapLinkedAccounts)
            }
            row(title: "로그아웃", showsChevron: false) {
                store.send(.didTapLogout)
            }
            row(title: "탈퇴하기", showsChevron: false) {
                store.send(.didTapWithdraw)
            }
            Spacer()
        }
        .baziBackground(.bgWhite)
    }

    private func row(title: String, showsChevron: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .baziFont(.body16R)
                    .foregroundStyle(Color.gray900)
                Spacer()
                if showsChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.gray400)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 22)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var logoutAlertOverlay: some View {
        ZStack {
            BZDimOverlay(level: .dim1)
                .onTapGesture { store.send(.didCancelLogout) }

            BZAlert(
                title: "로그아웃 할까요?",
                message: "현재 계정에서 로그아웃됩니다.\n다시 이용하려면 로그인해 주세요.",
                confirmTitle: "로그아웃",
                onCancel: { store.send(.didCancelLogout) },
                onConfirm: { store.send(.didConfirmLogout) },
                onClose: { store.send(.didCancelLogout) }
            )
            .padding(.horizontal, 40)
        }
        .ignoresSafeArea()
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
