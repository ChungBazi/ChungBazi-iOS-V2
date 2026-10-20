// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct EducationStepView: View {

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

extension EducationStepView {

    private var titleText: some View {
        Text(PolicyProfileConstants.Question.education)
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private var selectField: some View {
        BZSelectField(
            title: PolicyProfileConstants.SelectTitle.education,
            options: EducationUI.allCases.map(\.rawValue),
            selection: Binding(
                get: { store.education?.rawValue },
                set: { store.send(.didSelectEducation($0.flatMap(EducationUI.init(rawValue:)))) }
            )
        )
    }
}

// MARK: - Preview

#Preview {
    EducationStepView(
        store: Store(
            initialState: {
                var state = OnboardingContainerFeature.State()
                state.currentStep = .education
                return state
            }()
        ) {
            OnboardingContainerFeature()
        }
    )
}
