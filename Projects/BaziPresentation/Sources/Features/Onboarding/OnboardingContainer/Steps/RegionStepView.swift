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
        Text("거주 중인 지역을 선택해주세요")
            .baziFont(.head22B)
            .foregroundStyle(Color.grayBlack)
    }

    private var selectFields: some View {
        VStack(spacing: 12) {
            BZSelectField(
                title: "시/도 선택",
                placeholder: "시/도 선택",
                options: OnboardingContainerFeature.provinces,
                selection: $store.province
            )

            BZSelectField(
                title: "시/군/구 선택",
                placeholder: "시/군/구 선택",
                options: OnboardingContainerFeature.districts,
                selection: $store.district,
                isDisabled: store.province == nil
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
