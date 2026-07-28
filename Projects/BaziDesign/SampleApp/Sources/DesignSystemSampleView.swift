// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import SwiftUI

struct DesignSystemSampleView: View {

    // MARK: - Properties

    @State private var onboardingStep = 1
    @State private var nickname = ""
    @State private var region: String?
    @State private var selectedChips: Set<String> = []

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    typographySection
                    colorSection
                    buttonSection
                    onboardingStepSection
                    inputFieldSection
                    selectFieldSection
                    choiceChipSection
                }
                .padding(20)
            }
            .navigationTitle("BaziDesign")
        }
    }
}

// MARK: - Typography

extension DesignSystemSampleView {

    private var typographySection: some View {
        sectionContainer(title: "Typography") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(Array(BaziFont.allCases.enumerated()), id: \.offset) { _, font in
                    Text("\(String(describing: font)) — 정책을 확인해보세요")
                        .baziFont(font)
                }
            }
        }
    }
}

// MARK: - Color

extension DesignSystemSampleView {

    private var colorSamples: [(name: String, color: BaziColor)] {
        [
            ("primary", .primary),
            ("secondary", .secondary),
            ("bgGray", .bgGray),
            ("bgWhite", .bgWhite),
            ("accent", .accent),
            ("dim1", .dim1),
            ("dim2", .dim2),
        ]
    }

    private var colorSection: some View {
        sectionContainer(title: "Color") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(colorSamples, id: \.name) { sample in
                    HStack(spacing: 12) {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(sample.color.color)
                            .frame(width: 40, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .strokeBorder(.black.opacity(0.08), lineWidth: 1)
                            )
                        Text(sample.name)
                    }
                }
            }
        }
    }
}

// MARK: - BZButton

extension DesignSystemSampleView {

    private var buttonSection: some View {
        sectionContainer(title: "BZButton") {
            VStack(alignment: .leading, spacing: 16) {
                VStack(spacing: 12) {
                    BZButton("버튼", type: .cta) {}
                    BZButton("버튼", type: .normal) {}
                    BZButton("버튼", type: .normal2) {}
                    BZButton("버튼", type: .accent) {}
                }

                Text("Disabled").font(.caption).foregroundStyle(.secondary)
                BZButton("버튼", type: .cta) {}
                    .disabled(true)

                Text("Small / Medium (Dual)").font(.caption).foregroundStyle(.secondary)
                HStack(spacing: 10) {
                    BZButton("버튼", type: .normal, size: .small) {}
                    BZButton("버튼", type: .cta, size: .medium) {}
                }
            }
        }
    }
}

// MARK: - BZOnboardingStep

extension DesignSystemSampleView {

    private var onboardingStepSection: some View {
        sectionContainer(title: "BZOnboardingStep") {
            VStack(alignment: .leading, spacing: 12) {
                BZOnboardingStep(currentStep: onboardingStep)

                HStack(spacing: 12) {
                    BZButton("이전", type: .normal, size: .small) {
                        if onboardingStep > 1 { onboardingStep -= 1 }
                    }
                    BZButton("다음", type: .cta, size: .small) {
                        if onboardingStep < 6 { onboardingStep += 1 }
                    }
                    Text("\(onboardingStep)/6")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - BZInputField

extension DesignSystemSampleView {

    private var inputFieldSection: some View {
        sectionContainer(title: "BZInputField") {
            BZInputField(text: $nickname, placeholder: "닉네임을 입력해주세요")
        }
    }
}

// MARK: - BZSelectField (+ BZBottomSheet)

extension DesignSystemSampleView {

    private var selectFieldSection: some View {
        sectionContainer(title: "BZSelectField (탭하면 BZBottomSheet)") {
            BZSelectField(
                title: "지역을 선택해주세요",
                options: ["서울", "경기", "인천", "부산", "대구", "광주","서울"],
                selection: $region
            )
        }
    }
}

// MARK: - BZChoiceChip

extension DesignSystemSampleView {

    private var choiceChipSection: some View {
        sectionContainer(title: "BZChoiceChip") {
            let fields = ["취업·창업", "월세·주거", "공부·성장", "생활지원", "활동·경험"]
            let columns = [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)]
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(fields, id: \.self) { field in
                    BZChoiceChip(field, isSelected: selectedChips.contains(field)) {
                        if selectedChips.contains(field) {
                            selectedChips.remove(field)
                        } else {
                            selectedChips.insert(field)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Section Container

extension DesignSystemSampleView {

    private func sectionContainer<Content: View>(
        title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.bold())
            content()
        }
    }
}

// MARK: - Preview

#Preview {
    DesignSystemSampleView()
}
