// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct IncomeStepView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 36) {
            titleRow
            selectField
        }
    }
}

// MARK: - Subviews

extension IncomeStepView {

    private var titleRow: some View {
        HStack(spacing: 6) {
            Text(PolicyProfileConstants.Question.income)
                .baziFont(.head22B)
                .foregroundStyle(Color.grayBlack)

            IncomeInfoTooltipButton()
        }
    }

    private var selectField: some View {
        BZSelectField(
            title: PolicyProfileConstants.SelectTitle.income,
            options: IncomeLevelUI.allCases.map(\.rawValue),
            selection: Binding(
                get: { store.income?.rawValue },
                set: { store.send(.didSelectIncome($0.flatMap(IncomeLevelUI.init(rawValue:)))) }
            )
        )
    }
}

// MARK: - Preview

#Preview {
    IncomeStepView(
        store: Store(
            initialState: {
                var state = OnboardingContainerFeature.State()
                state.currentStep = .income
                return state
            }()
        ) {
            OnboardingContainerFeature()
        }
    )
}
