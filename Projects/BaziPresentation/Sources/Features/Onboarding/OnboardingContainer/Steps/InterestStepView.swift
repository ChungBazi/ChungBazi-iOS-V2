// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct InterestStepView: View {

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
            categoryGrid
        }
    }
}

// MARK: - Subviews

extension InterestStepView {

    private var titleText: some View {
        Text("관심 있는 분야를\n3개 이상 선택해주세요")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
            .multilineTextAlignment(.center)
    }

    private var subtitleText: some View {
        Text("선택한 항목은 나중에 언제든 수정할 수 있어요")
            .baziFont(.small14R)
            .foregroundStyle(Color.gray500)
    }
    
    private var categoryGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(InterestCategoryUI.allCases, id: \.self) { interest in
                BZChoiceChip(
                    interest.rawValue,
                    isSelected: store.interests.contains(interest)
                ) {
                    store.send(.didTapInterest(interest))
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InterestStepView(
        store: Store(
            initialState: {
                var state = OnboardingContainerFeature.State()
                state.currentStep = .interest
                return state
            }()
        ) {
            OnboardingContainerFeature()
        }
    )
}
