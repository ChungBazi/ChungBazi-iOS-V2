// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct BirthDateStepView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 90) {
            titleText
            BZBirthDatePicker(year: $store.year, month: $store.month, day: $store.day)
        }
    }
}

// MARK: - Subviews

extension BirthDateStepView {

    private var titleText: some View {
        Text("생년월일이 언제인가요?")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }
}

// MARK: - Preview

#Preview {
    BirthDateStepView(
        store: Store(initialState: .init()) {
            OnboardingContainerFeature()
        }
    )
}
