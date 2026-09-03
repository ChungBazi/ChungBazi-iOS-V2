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
        Text(PolicyProfileConstants.Question.employment)
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private var selectField: some View {
        BZSelectField(
            title: PolicyProfileConstants.SelectTitle.employment,
            options: EmploymentUI.allCases.map(\.rawValue),
            selection: Binding(
                get: { store.employment?.rawValue },
                set: { store.send(.didSelectEmployment($0.flatMap(EmploymentUI.init(rawValue:)))) }
            )
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
