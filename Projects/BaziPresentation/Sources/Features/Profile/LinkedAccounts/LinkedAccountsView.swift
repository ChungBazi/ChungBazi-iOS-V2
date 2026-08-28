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
        ScrollView {
            VStack(spacing: 12) {
                ForEach(store.accounts) { account in
                    accountRow(account)
                }
            }
            .padding(20)
        }
        .baziBackground(.bgWhite)
    }

    private func accountRow(_ account: SocialAccount) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(account.provider.displayName)
                    .baziFont(.small12M)
                    .foregroundStyle(Color.gray600)
                Text(account.email)
                    .baziFont(.body16R)
                    .foregroundStyle(Color.gray900)
            }

            Spacer()

            if store.isUnlinkEnabled {
                Button("해지") {
                    store.send(.didTapUnlink(id: account.id))
                }
                .baziFont(.small14SB)
                .foregroundStyle(Color.bazi(.accent))
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.blue50)
        .overlay(
            RoundedRectangle(cornerRadius: BaziRadius.medium.rawValue, style: .continuous)
                .strokeBorder(Color.blue200, lineWidth: 0.8)
        )
        .baziRadius(.medium)
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
