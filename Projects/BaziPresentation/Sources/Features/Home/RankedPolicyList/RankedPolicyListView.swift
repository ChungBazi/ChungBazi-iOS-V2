// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct RankedPolicyListView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<RankedPolicyListFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<RankedPolicyListFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle(store.kind.navigationTitle) {
                dismiss()
            }
    }
}

// MARK: - Subviews

extension RankedPolicyListView {

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !store.teaser.isEmpty {
                    teaserBanner
                }
                BZSegmentControl(
                    options: PolicyCategoryUI.allCases.map(\.rawValue),
                    selection: categorySelection
                ) { _ in EmptyView() }

                listSection
            }
        }
        .baziBackground(.bgGray)
        .refreshable { await store.send(.pullToRefresh).finish() }
    }

    private var teaserBanner: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(store.kind.bannerTitle)
                .baziFont(.head18B)
                .foregroundStyle(Color.gray900)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(store.teaser) { policy in
                        BZCard(
                            size: .small,
                            category: policy.category.rawValue,
                            dDay: policy.dDay,
                            title: policy.title,
                            viewCount: policy.viewCount,
                            isLiked: teaserLikeBinding(id: policy.id)
                        )
                        .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue100)
    }

    @ViewBuilder
    private var listSection: some View {
        switch store.list {
        case .idle, .loading:
            BZLoadingView()
                .frame(maxWidth: .infinity)
                .frame(height: 240)

        case .failed:
            BZRetryView { store.send(.didTapRetry) }
                .frame(height: 240)

        case .loaded(let policies):
            if policies.isEmpty {
                emptyView
            } else {
                policyList(policies)
            }
        }
    }

    private func policyList(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(policies.enumerated()), id: \.element.id) { index, policy in
                BZCard(
                    size: .medium2,
                    badgeNumber: store.kind.showsRankBadge ? index + 1 : nil,
                    category: policy.category.rawValue,
                    dDay: policy.dDay,
                    title: policy.title,
                    viewCount: policy.viewCount,
                    isLiked: likeBinding(id: policy.id)
                )
                .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
                .onAppear {
                    if policy.id == policies.last?.id {
                        store.send(.didReachListEnd)
                    }
                }
            }
        }
        .padding([.horizontal, .bottom], 20)
    }

    private var emptyView: some View {
        BZEmptyView(message: "조건에 맞는 정책이 없어요")
    }
}

// MARK: - Bindings

extension RankedPolicyListView {

    private var categorySelection: Binding<String> {
        Binding(
            get: { store.selectedCategory.rawValue },
            set: { newValue in
                guard let category = PolicyCategoryUI(rawValue: newValue) else { return }
                store.send(.didSelectCategory(category))
            }
        )
    }

    private func likeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.list.value?[id: id]?.isLiked ?? false },
            set: { _ in store.send(.didToggleLike(id: id)) }
        )
    }

    private func teaserLikeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.teaser[id: id]?.isLiked ?? false },
            set: { _ in store.send(.didToggleTeaserLike(id: id)) }
        )
    }
}

// MARK: - Preview

#Preview("인기 정책") {
    NavigationStack {
        RankedPolicyListView(
            store: Store(initialState: .init(kind: .popular)) {
                RankedPolicyListFeature()
            }
        )
    }
}

#Preview("마감 임박 정책") {
    NavigationStack {
        RankedPolicyListView(
            store: Store(initialState: .init(kind: .deadline)) {
                RankedPolicyListFeature()
            }
        )
    }
}

#Preview("새로 뜬 정책") {
    NavigationStack {
        RankedPolicyListView(
            store: Store(initialState: .init(kind: .latest)) {
                RankedPolicyListFeature()
            }
        )
    }
}

#Preview("목록 빔 · 티저 있음") {
    var state = RankedPolicyListFeature.State(kind: .popular)
    state.teaser = IdentifiedArray(uniqueElements: PolicySummaryVO.mockList)
    state.list = .loaded([])

    return NavigationStack {
        RankedPolicyListView(
            store: Store(initialState: state) {
                EmptyReducer()
            }
        )
    }
}

#Preview("목록 빔 · 티저 없음") {
    var state = RankedPolicyListFeature.State(kind: .popular)
    state.teaser = []
    state.list = .loaded([])

    return NavigationStack {
        RankedPolicyListView(
            store: Store(initialState: state) {
                EmptyReducer()
            }
        )
    }
}
