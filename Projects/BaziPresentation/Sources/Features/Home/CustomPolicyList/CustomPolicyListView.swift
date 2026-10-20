// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct CustomPolicyListView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<CustomPolicyListFeature>
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPolicyID: Int?

    // MARK: - Init

    public init(store: StoreOf<CustomPolicyListFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle(navigationTitle) {
                dismiss()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
    }

    private var navigationTitle: String {
        if let category = store.category {
            return "\(store.displayName)님의 \(category.rawValue) 맞춤 정책"
        }
        return "\(store.displayName)님의 맞춤 정책"
    }
}

// MARK: - Subviews

extension CustomPolicyListView {

    private var content: some View {
        Group {
            switch store.cards {
            case .idle, .loading:
                BZLoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case let .failed(message):
                BZRetryView(message: message) { store.send(.didTapRetry) }
            case .loaded(let cards):
                if cards.isEmpty {
                    emptyView
                } else {
                    loadedContent(cards)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [Color.blue200, Color.green50],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func loadedContent(_ cards: IdentifiedArrayOf<PolicyCardVO>) -> some View {
        ZStack {
            VStack(spacing: 0) {
                cardCarousel(cards)
                ctaButtons
            }

            if let guideStep = store.guideStep {
                guideOverlay(guideStep)
            }
        }
    }

    private func cardCarousel(_ cards: IdentifiedArrayOf<PolicyCardVO>) -> some View {
        GeometryReader { geo in
            let neighborPeek: CGFloat = 15 // 이웃 카드 노출 폭
            let cardSpacing: CGFloat = 20
            let inset = neighborPeek + cardSpacing
            let cardWidth = geo.size.width - inset * 2

            ScrollView(.horizontal) {
                LazyHStack(spacing: cardSpacing) {
                    ForEach(cards) { card in
                        BZFlipCard(
                            image: card.category.cardImage.image,
                            category: card.category.rawValue,
                            dDay: card.dDay,
                            title: card.title,
                            subtitle: card.summary,
                            applyPeriod: card.applyPeriod,
                            description: card.aiSummary.text ?? card.supportContent,
                            isSummarizing: card.aiSummary.isLoading,
                            isLiked: likeBinding(id: card.id),
                            onFlip: { showingBack in store.send(.didFlipCard(id: card.id, showingBack: showingBack)) }
                        )
                        .frame(width: cardWidth)
                        .id(card.id)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, inset, for: .scrollContent)
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $selectedPolicyID)
            .scrollIndicators(.hidden)
            .scrollClipDisabled()
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxHeight: .infinity)
        }
        // 최초 노출 시에만 첫 카드로 맞춘다(재노출 시 보던 카드 유지).
        .onAppear { if selectedPolicyID == nil { selectedPolicyID = cards.first?.id } }
        .onChange(of: selectedPolicyID) { _, newID in
            if let newID { store.send(.didShowCard(id: newID)) }
        }
    }

    private var ctaButtons: some View {
        VStack(spacing: 12) {
            BZButton("바로 신청하러 가기", type: .cta) {
                guard let selectedPolicyID else { return }
                store.send(.didTapApply(id: selectedPolicyID))
            }
            .disabled(applyURL == nil)
            BZButton("자세한 정보 더 보기", type: .normal2) {
                guard let selectedPolicyID else { return }
                store.send(.didTapDetail(id: selectedPolicyID))
            }
        }
        .padding([.top, .horizontal], 20)
        .padding(.bottom, 5)
    }

    /// 현재 선택된 카드의 신청 링크. 값이 없거나 URL로 변환 불가하면 nil(버튼 비활성).
    private var applyURL: URL? {
        guard
            let selectedPolicyID,
            let urlString = store.cards.value?[id: selectedPolicyID]?.applyUrl
        else { return nil }
        return URL(string: urlString)
    }

    private var emptyView: some View {
        BZEmptyView(message: "맞춤 정책이 없어요")
            .frame(maxHeight: .infinity)
    }

    private func guideOverlay(_ step: CustomPolicyListFeature.GuideStep) -> some View {
        ZStack {
            Color.bazi(.dim2).ignoresSafeArea()

            VStack(spacing: 44) {
                VStack(spacing: 20) {
                    Image.bazi(step.illustration)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 119)
                        .foregroundStyle(Color.grayWhite)
                        .accessibilityHidden(true)
                    Text(step.message)
                        .baziFont(.head18B)
                        .foregroundStyle(Color.grayWhite)
                        .multilineTextAlignment(.center)
                }

                BZButton(step.buttonTitle, type: .normal, size: .small) {
                    store.send(.didTapGuideNext)
                }
            }
        }
    }
}

// MARK: - Bindings

extension CustomPolicyListView {

    private func likeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.likeOverrides[id] ?? (store.cards.value?[id: id]?.isLiked ?? false) },
            set: { _ in store.send(.didToggleLike(id: id)) }
        )
    }
}

// MARK: - Preview

#Preview("가이드") {
    var state = CustomPolicyListFeature.State()
    state.displayName = "바지"
    state.cards = .loaded(IdentifiedArray(uniqueElements: PolicyCardVO.mockList))
    state.guideStep = .swipeHint

    return NavigationStack {
        CustomPolicyListView(
            store: Store(initialState: state) {
                CustomPolicyListFeature()
            }
        )
    }
}

#Preview("가이드 없음") {
    var state = CustomPolicyListFeature.State()
    state.displayName = "바지"
    state.cards = .loaded(IdentifiedArray(uniqueElements: PolicyCardVO.mockList))
    state.guideStep = nil

    return NavigationStack {
        CustomPolicyListView(
            store: Store(initialState: state) {
                CustomPolicyListFeature()
            }
        )
    }
}

#Preview("맞춤 정책 없음") {
    var state = CustomPolicyListFeature.State()
    state.displayName = "바지"
    state.cards = .loaded([])

    return NavigationStack {
        CustomPolicyListView(
            store: Store(initialState: state) {
                EmptyReducer()
            }
        )
    }
}
