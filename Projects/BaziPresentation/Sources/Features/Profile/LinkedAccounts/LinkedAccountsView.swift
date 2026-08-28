// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct LinkedAccountsView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<LinkedAccountsFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<LinkedAccountsFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("로그인된 소셜 계정") {
                dismiss()
            }
    }
}

// MARK: - Subviews

extension LinkedAccountsView {

    private var content: some View {
        VStack {
            ForEach(store.accounts) { account in
                accountRow(account)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .baziBackground(.bgWhite)
    }

    private func accountRow(_ account: SocialAccount) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image.bazi(.kakaoIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12)
                
                Text(account.provider.displayName)
                    .baziFont(.small14R)
                    .foregroundStyle(Color.gray800)
            }
            Text(account.email)
                .baziFont(.body16R)
                .foregroundStyle(Color.gray900)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue50)
        .baziRadius(.small)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LinkedAccountsView(
            store: Store(initialState: .init()) {
                LinkedAccountsFeature()
            }
        )
    }
}
