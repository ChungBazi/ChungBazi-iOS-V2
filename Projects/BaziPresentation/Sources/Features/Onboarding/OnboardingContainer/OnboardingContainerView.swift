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
        VStack(spacing: 0) {
            // 단계나 본문 레이아웃이 바뀌어도 동일한 진행 바를 유지한다.
            BZOnboardingStep(
                currentStep: store.currentStep.rawValue,
                totalSteps: OnboardingContainerFeature.Step.allCases.count
            )
                .padding(.top, 28)

            adaptiveStepContent
                .frame(maxHeight: .infinity, alignment: .top)

            buttonRow
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 20)
        .baziBackground(.bgWhite)
    }

    @ViewBuilder
    private var adaptiveStepContent: some View {
        if store.currentStep == .specialEligibility || store.currentStep == .interest {
            // 진행 바와 버튼은 교체하지 않고 본문의 위아래 여백만 선택한다.
            ViewThatFits(in: .vertical) {
                paddedStepContent(spacing: 64)
                paddedStepContent(spacing: 32)
            }
        } else {
            paddedStepContent(spacing: 64)
        }
    }

    private func paddedStepContent(spacing: CGFloat) -> some View {
        stepContent
            .frame(maxHeight: .infinity, alignment: .top)
            .padding(.vertical, spacing)
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
