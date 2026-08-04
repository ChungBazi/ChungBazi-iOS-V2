// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import SwiftUI

struct DesignSystemSampleView: View {

    // MARK: - Properties

    @State private var category = "Foundation"

    @State private var onboardingStep = 1
    @State private var nickname = ""
    @State private var region: String?
    @State private var selectedChips: Set<String> = []

    @State private var isCardSBookmarked = true
    @State private var isCardMBookmarked = false
    @State private var isFlipCardBookmarked = true

    @State private var segmentDemoSelection = "전체"
    @State private var selectedTabBarItem: BZTabBarItem = .home
    @State private var isToastPresented = false

    private let categories = ["Foundation", "Button", "Onboarding", "NavBar", "Card", "Overlay"]

    // MARK: - Body

    var body: some View {
        BZSegmentControl(options: categories, selection: $category) { selected in
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    content(for: selected)
                }
                .padding(20)
            }
            .baziBackground(.bgGray)
        }
    }

    @ViewBuilder
    private func content(for category: String) -> some View {
        switch category {
        case "Foundation":
            typographySection
            colorSection

        case "Button":
            buttonSection
            circleButtonSection

        case "Onboarding":
            onboardingStepSection
            inputFieldSection
            selectFieldSection
            choiceChipSection

        case "NavBar":
            tabBarSection
            segmentControlSection

        case "Card":
            tagSection
            cardSection
            alarmCardSection
            flipCardSection

        case "Overlay":
            dimSection
            alertSection
            toastSection

        default:
            EmptyView()
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

// MARK: - BZCircleButton

extension DesignSystemSampleView {

    private var circleButtonSection: some View {
        sectionContainer(title: "BZCircleButton") {
            BZCircleButton {}
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
                options: ["서울", "경기", "인천", "부산", "대구", "광주", "서울"],
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

// MARK: - BZTabBar

extension DesignSystemSampleView {

    private var tabBarSection: some View {
        sectionContainer(title: "BZTabBar (NaviBar1 · NaviBar2)") {
            VStack(alignment: .leading, spacing: 8) {
                Text("캡슐형(iOS 26+)/평면형(iOS 18 이하)은 OS가 자동으로 그려준다.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                BZTabBar(selection: $selectedTabBarItem) { item in
                    Color.bazi(.bgGray)
                        .overlay(Text("\(item.id)"))
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
    }
}

// MARK: - BZSegmentControl

extension DesignSystemSampleView {

    private var segmentControlSection: some View {
        sectionContainer(title: "BZSegmentControl") {
            BZSegmentControl(
                options: ["전체", "취업·창업", "월세·주거", "공부·성장", "생활지원", "활동·경험"],
                selection: $segmentDemoSelection
            ) { selected in
                Text("\(selected) 콘텐츠")
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            }
        }
    }
}

// MARK: - BZTag

extension DesignSystemSampleView {

    private var tagSection: some View {
        sectionContainer(title: "BZTag") {
            HStack(spacing: 8) {
                BZTag("텍스트", type: .green)
                BZTag("텍스트", type: .blue100)
                BZTag("텍스트", type: .blue200)
            }
        }
    }
}

// MARK: - BZCard

extension DesignSystemSampleView {

    private var cardSection: some View {
        sectionContainer(title: "BZCard") {
            VStack(alignment: .leading, spacing: 16) {
                // medium/medium2는 너비가 max라 가로 스크롤 묶음과 분리해 풀와이드로 보여준다.
                BZCard(
                    size: .medium,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털 직무역량 연계...",
                    viewCount: 15200,
                    isBookmarked: $isCardMBookmarked
                )
                BZCard(
                    size: .medium2,
                    badgeNumber: 1,
                    category: "취업·창업",
                    dDay: "D-11",
                    title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청 연계청년 디지털 직무역량 연계...",
                    viewCount: 15200,
                    isBookmarked: $isCardMBookmarked
                )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 16) {
                        BZCard(
                            size: .small,
                            category: "취업·창업",
                            dDay: "D-11",
                            title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청...",
                            viewCount: 15200,
                            isBookmarked: $isCardSBookmarked
                        )
                        BZCard(
                            size: .large,
                            category: "취업·창업",
                            dDay: "D-11",
                            title: "2026 지역특화산업 연계청년 디지털 직무역량 연계청...",
                            viewCount: 15200,
                            isBookmarked: $isCardSBookmarked
                        )
                    }
                }
            }
        }
    }
}

// MARK: - BZAlarmCard

extension DesignSystemSampleView {

    private var alarmCardSection: some View {
        sectionContainer(title: "BZAlarmCard (왼쪽으로 스와이프하면 삭제)") {
            List {
                BZAlarmCard(
                    title: "찜한 정책 신청 마감이 하루 남았어요",
                    message: "민재님이 찜한 정책인 '청년 월세 특별지원 사업' 신청이 내일 마감돼요!",
                    timeAgo: "17분전"
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .baziAlarmCardSwipeToDelete {}
            }
            .listStyle(.plain)
            .scrollDisabled(true)
            .frame(height: 140)
        }
    }
}

// MARK: - BZFlipCard

extension DesignSystemSampleView {

    private var flipCardSection: some View {
        sectionContainer(title: "BZFlipCard (탭하면 뒤집힘)") {
            BZFlipCard(
                category: "월세·주거",
                dDay: "D-11",
                title: "청년 맞춤형 주거복지 확대를 위한 전·월세 금융지원 및 월세 지원 사업",
                subtitle: "소속 근로자가 일·생활 균형을 위해 유연근무제를 활용하게 하는 중소, 중견기업에게 장려금을 지원",
                applyPeriod: "2025.05.03 - 2025.06.30",
                description: "서울 청년취업사관학교는 청년들의 실무 역량을 키우고 취업까지 이어질 수 있도록 돕는 교육 프로그램이에요. 디지털·IT 분야를 중심으로 현장에서 활용할 수 있는 실무 교육과 프로젝트 기반 수업을 제공해요.",
                isBookmarked: $isFlipCardBookmarked
            )
        }
    }
}

// MARK: - BZDimOverlay

extension DesignSystemSampleView {

    private var dimSection: some View {
        sectionContainer(title: "BZDimOverlay") {
            HStack(spacing: 12) {
                dimSample(level: .dim1, label: "dim1 (45%)")
                dimSample(level: .dim2, label: "dim2 (80%)")
            }
        }
    }

    private func dimSample(level: BZDimLevel, label: String) -> some View {
        ZStack {
            Color.bazi(.bgGray)
            BZDimOverlay(level: level)
            Text(label)
                .foregroundStyle(.white)
        }
        .frame(height: 100)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - BZAlert

extension DesignSystemSampleView {

    private var alertSection: some View {
        sectionContainer(title: "BZAlert") {
            ZStack {
                Color.bazi(.bgGray)
                VStack(spacing: 16) {
                    BZAlert(title: "텍스트", message: "텍스트", onConfirm: {})
                    BZAlert(
                        title: "정책을 삭제할까요?",
                        message: "삭제하면 되돌릴 수 없어요",
                        confirmTitle: "삭제",
                        confirmType: .accent,
                        onConfirm: {}
                    )
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

// MARK: - BZToastMessage

extension DesignSystemSampleView {

    private var toastSection: some View {
        sectionContainer(title: "BZToastMessage") {
            BZButton("토스트 띄우기", type: .normal, size: .small) {
                isToastPresented = true
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .baziToast(isPresented: $isToastPresented, message: "텍스트", edge: .top)
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
