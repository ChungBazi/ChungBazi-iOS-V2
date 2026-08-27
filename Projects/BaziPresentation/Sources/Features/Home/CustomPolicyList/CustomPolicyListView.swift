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
            .task { store.send(.task) }
            .baziNavigationBar_backWithTitle(navigationTitle) {
                dismiss()
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
    }

    private var navigationTitle: String {
        if let category = store.category {
            return "\(store.userName)님의 \(category.rawValue) 맞춤 정책"
        }
        return "\(store.userName)님의 맞춤 정책"
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
            case .failed:
                BZRetryView { store.send(.didTapRetry) }
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
                            description: card.supportContent,
                            isBookmarked: bookmarkBinding(id: card.id)
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
        .onAppear { selectedPolicyID = cards.first?.id }
    }

    private var ctaButtons: some View {
        VStack(spacing: 12) {
            // TODO: 신청 외부 링크(ModalRoute.webView)가 준비되면 선택된 카드의 applyUrl로 연결한다.
            BZButton("바로 신청하러 가기", type: .cta) {}
            BZButton("자세한 정보 더 보기", type: .normal) {
                guard let selectedPolicyID else { return }
                store.send(.didTapDetail(id: selectedPolicyID))
            }
        }
        .padding(20)
    }

    private var emptyView: some View {
        Text("맞춤 정책이 없어요")
            .baziFont(.body16R)
            .foregroundStyle(Color.gray600)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

    private func bookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.cards.value?[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleBookmark(id: id)) }
        )
    }
}

// MARK: - Preview

#Preview("가이드") {
    var state = CustomPolicyListFeature.State()
    state.userName = "바지"
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
    state.userName = "바지"
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
