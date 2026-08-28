// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct ProfileView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<ProfileFeature>

    // MARK: - Init

    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            content
                .task { store.send(.onAppear) }
                .toolbar(.hidden, for: .navigationBar)
        } destination: { store in
            switch store.case {
            case .infoEdit(let store):
                ProfileInfoEditView(store: store)
            case .nicknameEdit(let store):
                NicknameEditView(store: store)
            case .linkedAccounts(let store):
                LinkedAccountsView(store: store)
            case .withdraw(let store):
                WithdrawView(store: store)
            case .policyProfileEdit(let store):
                PolicyProfileEditView(store: store)
            case .notificationSetting(let store):
                NotificationSettingView(store: store)
            case .terms(let store):
                TermsOfServiceView(store: store)
            case .privacy(let store):
                PrivacyPolicyView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension ProfileView {

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                avatar
                rows
            }
        }
        .baziBackground(.bgWhite)
        .background(Color.bazi(.bgWhite).ignoresSafeArea())
    }

    private var header: some View {
        BZNavigationRowHeader(title: store.nickname) {
            store.send(.didTapProfileHeader)
        }
    }

    private var avatar: some View {
        Circle()
            .fill(Color.blue100)
            .frame(width: 96, height: 96)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.bazi(.primary))
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .baziBackground(.bgWhite)
    }

    private var rows: some View {
        VStack(spacing: 0) {
            row(title: "알림 설정") { store.send(.didTapNotificationSettingRow) }
            row(title: "정책 맞춤 조건 수정") { store.send(.didTapPolicyProfileRow) }
            row(title: "서비스 이용약관") { store.send(.didTapTermsRow) }
            row(title: "개인정보 처리방침") { store.send(.didTapPrivacyRow) }
            staticRow(title: "문의하기")
            staticRow(title: "현재 버전 2.0")
        }
        .padding(.top, 8)
        .baziBackground(.bgWhite)
    }

    private func row(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            rowContent(title: title, showsChevron: true)
        }
        .buttonStyle(.plain)
    }

    private func staticRow(title: String) -> some View {
        rowContent(title: title, showsChevron: false)
    }

    private func rowContent(title: String, showsChevron: Bool) -> some View {
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
        .padding(.vertical, 18)
        .contentShape(Rectangle())
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
