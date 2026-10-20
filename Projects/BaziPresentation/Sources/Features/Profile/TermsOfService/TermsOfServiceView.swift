// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct TermsOfServiceView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<TermsOfServiceFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<TermsOfServiceFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        StaticTextDocumentView(
            title: "서비스 이용약관",
            text: ProfileConstants.LegalDocument.termsOfService,
            onAppear: { store.send(.onAppear) },
            onBack: { dismiss() }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        TermsOfServiceView(
            store: Store(initialState: .init()) {
                TermsOfServiceFeature()
            }
        )
    }
}
