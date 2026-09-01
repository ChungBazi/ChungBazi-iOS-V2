// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct PolicyProfileEditView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<PolicyProfileEditFeature>
    @Environment(\.dismiss) private var dismiss

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    // MARK: - Init

    public init(store: StoreOf<PolicyProfileEditFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("정책 맞춤 조건 수정") {
                dismiss()
            }
            .baziToast(isPresented: $store.isSuccessToastPresented, message: "정책 맞춤 조건이 수정되었어요")
    }
}

// MARK: - Subviews

extension PolicyProfileEditView {

    private var content: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                birthDateSection
                regionSection
                educationSection
                employmentSection
                incomeSection
                specialEligibilitySection
                interestSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 95)
        }
        .safeAreaInset(edge: .bottom) {
            saveButton
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(Color.bazi(.bgWhite))
        }
        .baziBackground(.bgWhite)
    }

    private func questionTitle(_ number: Int, _ text: String) -> some View {
        Text("\(number). \(text)")
            .baziFont(.body16SB)
            .foregroundStyle(Color.gray900)
    }
}

// MARK: - BirthDate

extension PolicyProfileEditView {

    private var birthDateSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(1, "생년월일이 언제인가요?")
            BZBirthDatePicker(year: $store.year, month: $store.month, day: $store.day)
        }
    }
}

// MARK: - Region / Education / Employment / Income

extension PolicyProfileEditView {

    private var regionSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(2, "거주 중인 지역을 선택해주세요")
            VStack(spacing: 8) {
                BZSelectField(
                    title: "시/도 선택",
                    placeholder: "시/도 선택",
                    options: store.sidoOptions.map(\.name),
                    selection: Binding(
                        get: { store.selectedSido?.name },
                        set: { name in store.send(.didSelectSido(store.sidoOptions.first { $0.name == name })) }
                    )
                )
                BZSelectField(
                    title: "시/군/구 선택",
                    placeholder: "시/군/구 선택",
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

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(3, "현재 어떤 학업 단계에 있나요?")
            BZSelectField(
                title: "학업 단계 선택",
                options: EducationUI.allCases.map(\.rawValue),
                selection: Binding(
                    get: { store.education?.rawValue },
                    set: { store.send(.didSelectEducation($0.flatMap(EducationUI.init(rawValue:)))) }
                )
            )
        }
    }

    private var employmentSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(4, "현재 하고 있는 일이 있나요?")
            BZSelectField(
                title: "직업 형태 선택",
                options: EmploymentUI.allCases.map(\.rawValue),
                selection: Binding(
                    get: { store.employment?.rawValue },
                    set: { store.send(.didSelectEmployment($0.flatMap(EmploymentUI.init(rawValue:)))) }
                )
            )
        }
    }

    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            HStack {
                questionTitle(5, "현재 소득분위가 어떻게 되나요?")
                Spacer()
                IncomeInfoTooltipButton()
            }
            BZSelectField(
                title: "소득 분위 선택",
                options: IncomeLevelUI.allCases.map(\.rawValue),
                selection: Binding(
                    get: { store.income?.rawValue },
                    set: { store.send(.didSelectIncome($0.flatMap(IncomeLevelUI.init(rawValue:)))) }
                )
            )
        }
    }
}

// MARK: - Special Eligibility

extension PolicyProfileEditView {

    private var specialEligibilitySection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(6, "나에게 해당하는 항목을 모두 선택해 주세요")

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
}

// MARK: - Interest

extension PolicyProfileEditView {

    private var interestSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            VStack(alignment: .leading, spacing: 4) {
                questionTitle(7, "관심 있는 분야를 선택해주세요")
                Text("3개 이상 선택 필수")
                    .font(.bazi(.small12R))
                    .foregroundStyle(Color.bazi(.accent))
            }
            
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

    private var saveButton: some View {
        BZButton("저장하기") {
            store.send(.didTapSaveButton)
        }
        .baziToastAnchor()
        .disabled(!store.isSaveEnabled)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PolicyProfileEditView(
            store: Store(initialState: .init()) {
                PolicyProfileEditFeature()
            }
        )
    }
}
