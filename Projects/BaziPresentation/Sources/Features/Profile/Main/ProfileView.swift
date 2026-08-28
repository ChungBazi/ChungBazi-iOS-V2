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
            Group {
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
            // 프로필에서 push되는 모든 화면은 하단 탭바를 숨긴다.
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

// MARK: - Subviews

extension ProfileView {

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                profileImage
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

    private var profileImage: some View {
        RoundedRectangle(cornerRadius: 33)
            .fill(Color.bazi(.secondary))
            .frame(width: 140, height: 140)
            .overlay {
                Image.bazi(.basicBaro)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 91)
            }
    }

    private var rows: some View {
        VStack(spacing: 0) {
            ProfileRow("알림 설정") { store.send(.didTapNotificationSettingRow) }
            ProfileRow("정책 맞춤 조건 수정") { store.send(.didTapPolicyProfileRow) }
            ProfileRow("서비스 이용약관") { store.send(.didTapTermsRow) }
            ProfileRow("개인정보 처리방침") { store.send(.didTapPrivacyRow) }
            ProfileRow("문의하기") { }
            ProfileRow("현재 버전 2.0") { }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .baziBackground(.bgWhite)
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
