// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct SpecialEligibilityStepView: View {

    // MARK: - Properties

    let store: StoreOf<OnboardingContainerFeature>

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    // MARK: - Body

    var body: some View {
        VStack(spacing: 20) {
            titleText
            subtitleText
                .padding(.bottom, 16)
            chipGrid
        }
    }
}

// MARK: - Subviews

extension SpecialEligibilityStepView {

    private var titleText: some View {
        Text("나에게 해당하는 항목을\n모두 선택해 주세요")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
            .multilineTextAlignment(.center)
    }

    private var subtitleText: some View {
        Text("해당하는 항목이 없다면 '해당 없어요'를 선택해 주세요")
            .baziFont(.small14R)
            .foregroundStyle(Color.gray500)
    }

    private var chipGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(SpecialEligibilityUI.allCases, id: \.self) { item in
                BZChoiceChip(
                    item.rawValue,
                    isSelected: store.specialEligibilities.contains(item)
                ) {
                    store.send(.didTapSpecialEligibility(item))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SpecialEligibilityStepView(
        store: Store(
            initialState: {
                var state = OnboardingContainerFeature.State()
                state.currentStep = .specialEligibility
                return state
            }()
        ) {
            OnboardingContainerFeature()
        }
    )
}
