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
            .task { store.send(.task) }
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
                    options: PolicyCategory.allCases.map(\.rawValue),
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
                            isBookmarked: teaserBookmarkBinding(id: policy.id)
                        )
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
                emptyText
            } else {
                policyList(policies)
            }
        }
    }

    private func policyList(_ policies: IdentifiedArrayOf<PolicySummary>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(policies.enumerated()), id: \.element.id) { index, policy in
                BZCard(
                    size: .medium2,
                    badgeNumber: store.kind.showsRankBadge ? index + 1 : nil,
                    category: policy.category.rawValue,
                    dDay: policy.dDay,
                    title: policy.title,
                    viewCount: policy.viewCount,
                    isBookmarked: bookmarkBinding(id: policy.id)
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

    private var emptyText: some View {
        Text("조건에 맞는 정책이 없어요")
            .baziFont(.small14R)
            .foregroundStyle(Color.gray400)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
    }
}

// MARK: - Bindings

extension RankedPolicyListView {

    private var categorySelection: Binding<String> {
        Binding(
            get: { store.selectedCategory.rawValue },
            set: { newValue in
                guard let category = PolicyCategory(rawValue: newValue) else { return }
                store.send(.didSelectCategory(category))
            }
        )
    }

    private func bookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.list.value?[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleBookmark(id: id)) }
        )
    }

    private func teaserBookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.teaser[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleTeaserBookmark(id: id)) }
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
