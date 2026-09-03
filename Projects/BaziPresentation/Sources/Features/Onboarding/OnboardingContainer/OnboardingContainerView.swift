// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct OnboardingContainerView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>

    // MARK: - Init

    public init(store: StoreOf<OnboardingContainerFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .task { store.send(.onAppear) }
            .baziToast(errorMessage: $store.errorToast)
    }
}

// MARK: - Subviews

extension OnboardingContainerView {

    private var content: some View {
        VStack(spacing: 64) {
            BZOnboardingStep(
                currentStep: store.currentStep.rawValue,
                totalSteps: OnboardingContainerFeature.Step.allCases.count
            )
                .padding(.top, 28)
            
            stepContent
            Spacer()
            buttonRow
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 20)
        .baziBackground(.bgWhite)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch store.currentStep {
        case .birthDate:
            BirthDateStepView(store: store)

        case .region:
            RegionStepView(store: store)

        case .education:
            EducationStepView(store: store)

        case .employment:
            EmploymentStepView(store: store)

        case .income:
            IncomeStepView(store: store)

        case .specialEligibility:
            SpecialEligibilityStepView(store: store)

        case .interest:
            InterestStepView(store: store)
        }
    }

    private var buttonRow: some View {
        HStack(spacing: 10) {
            BZButton("이전으로", type: .normal, size: .small) {
                store.send(.didTapPreviousButton)
            }
            .disabled(store.isSubmitting)

            BZButton("다음으로", type: .cta, size: .medium) {
                store.send(.didTapNextButton)
            }
            .disabled(!store.isCurrentStepValid || store.isSubmitting)
        }
    }
}

// MARK: - Preview

#Preview {
    OnboardingContainerView(
        store: Store(initialState: .init()) {
            OnboardingContainerFeature()
        }
    )
}
