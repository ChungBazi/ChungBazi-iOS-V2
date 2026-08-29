// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct PrivacyPolicyView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<PrivacyPolicyFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<PrivacyPolicyFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        StaticTextDocumentView(
            title: "개인정보 처리방침",
            text: ProfileConstants.LegalDocument.privacyPolicy,
            onAppear: { store.send(.onAppear) },
            onBack: { dismiss() }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PrivacyPolicyView(
            store: Store(initialState: .init()) {
                PrivacyPolicyFeature()
            }
        )
    }
}
