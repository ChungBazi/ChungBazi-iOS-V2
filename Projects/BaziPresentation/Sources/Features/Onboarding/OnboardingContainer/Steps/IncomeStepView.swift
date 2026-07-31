// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

struct IncomeStepView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<OnboardingContainerFeature>
    @State private var isTooltipPresented = false

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
            Text("현재 소득분위가 어떻게 되나요?")
                .baziFont(.head22B)
                .foregroundStyle(Color.grayBlack)

            Button {
                isTooltipPresented = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.gray500)
            }
            .sheet(isPresented: $isTooltipPresented) {
                tooltipSheetView
                    .presentationDetents([.height(350)])
                    .presentationDragIndicator(.visible)
            }
        }
    }

    private var selectField: some View {
        BZSelectField(
            title: "소득 분위 선택",
            options: OnboardingContainerFeature.incomeOptions,
            selection: $store.income
        )
    }
    
    private var tooltipSheetView: some View {
        VStack(spacing: 18) {
            Text("소득분위가 뭔가요?")
                .baziFont(.body16SB)
                .foregroundStyle(Color.gray900)
            Text("소득분위는 가구 소득을 기준으로 전체 인구를 10등급으로 나눈 것이에요. 1분위에 가까울수록 소득이 낮고, 10분위에 가까울수록 소득이 높아요.".byCharWrapping)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray700)
                .frame(maxWidth: .infinity, alignment: .leading)
            boxTextView
            Text("모르겠다면 '잘 모르겠어요'를 선택해도 괜찮아요.\n프로필에서 나중에 수정할 수 있어요.".byCharWrapping)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray500)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .baziBackground(.bgWhite)
    }
    
    private var boxTextView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("어디서 확인하나요?")
                .baziFont(.small14SB)
                .foregroundStyle(Color.bazi(.primary))
            Text("건강보험료 납부 금액으로 대략 확인할 수 있어요.\n국민건강보험 앱 또는 홈페이지에서 조회 가능해요.")
                .baziFont(.small14R)
                .foregroundStyle(Color.gray700)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 17)
        .background(Color.blue50)
        .baziRadius(.small)
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
