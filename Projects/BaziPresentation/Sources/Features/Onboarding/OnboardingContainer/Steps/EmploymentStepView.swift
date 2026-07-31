// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct EmploymentStepView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 36) {
            titleText
            selectField
        }
    }
}

// MARK: - Subviews

extension EmploymentStepView {

    private var titleText: some View {
        Text("현재 하고 있는 일이 있나요?")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private var selectField: some View {
        BZSelectField(
            title: "취업 상태 선택",
            options: OnboardingContainerFeature.employmentOptions,
            selection: $store.employment
        )
    }
}

// MARK: - Preview

#Preview {
    EmploymentStepView(
        store: Store(
            initialState: {
                var state = OnboardingContainerFeature.State()
                state.currentStep = .employment
                return state
            }()
        ) {
            OnboardingContainerFeature()
        }
    )
}
