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
                interestSection
                saveButton
                    .padding(.top, 52)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 5)
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
                    options: store.sidoList.map(\.name),
                    selection: $store.province
                )
                BZSelectField(
                    title: "시/군/구 선택",
                    placeholder: "시/군/구 선택",
                    options: store.sigunguList.map(\.name),
                    selection: $store.district,
                    isDisabled: store.province == nil
                )
            }
        }
    }

    private var educationSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(3, "현재 어떤 학업 단계에 있나요?")
            BZSelectField(
                title: "학업 단계 선택",
                options: PolicyProfileEditFeature.educationOptions,
                selection: $store.education
            )
        }
    }

    private var employmentSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            questionTitle(4, "현재 하고 있는 일이 있나요?")
            BZSelectField(
                title: "직업 형태 선택",
                options: PolicyProfileEditFeature.employmentOptions,
                selection: $store.employment
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
                options: PolicyProfileEditFeature.incomeOptions,
                selection: $store.income
            )
        }
    }
}

// MARK: - Interest

extension PolicyProfileEditView {

    private var interestSection: some View {
        VStack(alignment: .leading, spacing: 19) {
            VStack(alignment: .leading, spacing: 4) {
                questionTitle(6, "관심 있는 분야를 선택해주세요")
                Text("3개 이상 선택 필수")
                    .font(.bazi(.small12R))
                    .foregroundStyle(Color.bazi(.accent))
            }
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(PolicyProfileEditFeature.interestCategories, id: \.self) { category in
                    BZChoiceChip(
                        category,
                        isSelected: store.selectedCategories.contains(category)
                    ) {
                        store.send(.didTapCategory(category))
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
