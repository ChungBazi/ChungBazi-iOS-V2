// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct RegionStepView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>

    // MARK: - Body

    var body: some View {
        VStack(spacing: 36) {
            titleText
            selectFields
        }
    }
}

// MARK: - Subviews

extension RegionStepView {

    private var titleText: some View {
        Text(PolicyProfileConstants.Question.region)
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private var selectFields: some View {
        VStack(spacing: 12) {
            BZSelectField(
                title: PolicyProfileConstants.SelectTitle.sido,
                placeholder: PolicyProfileConstants.SelectTitle.sido,
                options: store.sidoOptions.map(\.name),
                selection: Binding(
                    get: { store.selectedSido?.name },
                    set: { name in store.send(.didSelectSido(store.sidoOptions.first { $0.name == name })) }
                )
            )

            BZSelectField(
                title: PolicyProfileConstants.SelectTitle.sigungu,
                placeholder: PolicyProfileConstants.SelectTitle.sigungu,
                options: store.sigunguOptions.map(\.name),
                selection: Binding(
                    get: { store.selectedSigungu?.name },
                    set: { name in store.send(.didSelectSigungu(store.sigunguOptions.first { $0.name == name })) }
                ),
                isDisabled: store.selectedSido == nil
            )
        }
    }
}

// MARK: - Preview

#Preview {
    RegionStepView(
        store: Store(
            initialState: {
                var state = OnboardingContainerFeature.State()
                state.currentStep = .region
                return state
            }()
        ) {
            OnboardingContainerFeature()
        }
    )
}
