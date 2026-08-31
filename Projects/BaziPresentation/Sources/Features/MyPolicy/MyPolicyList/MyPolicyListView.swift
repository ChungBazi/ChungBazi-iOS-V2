// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct MyPolicyListView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<MyPolicyListFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<MyPolicyListFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .baziNavigationBar_backWithTitle("내 정책 전체보기") {
                dismiss()
            }
            .toolbar(.hidden, for: .tabBar)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Color.clear.frame(height: 0)
            }
    }
}

// MARK: - Subviews

extension MyPolicyListView {

    private var content: some View {
        // 카테고리 필터는 상단 고정, 그 아래 상태(로딩/에러/빈/리스트)를 그린다.
        VStack(spacing: 0) {
            categoryFilter
            stateContent
        }
        .baziBackground(.bgGray)
    }

    @ViewBuilder
    private var stateContent: some View {
        switch store.list {
        case .idle, .loading:
            BZLoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .failed:
            BZRetryView { store.send(.didTapRetry) }

        case .loaded(let policies):
            // 다른 화면에서 찜 해제된 정책(overlay == false)은 제외한다.
            let visiblePolicies = IdentifiedArray(uniqueElements: policies.filter { store.likeOverrides[$0.id] != false })
            // 정책이 없어도 결과바(갯수/정렬)는 항상 표시한다(내 정책 메인과 동일).
            resultsToolbar
            if visiblePolicies.isEmpty {
                emptyView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    policyList(visiblePolicies)
                }
                .refreshable { await store.send(.pullToRefresh).finish() }
            }
        }
    }

    private static let allCategoryTitle = "전체"

    private var categoryFilter: some View {
        BZSegmentControl(
            options: [Self.allCategoryTitle] + PolicyCategoryUI.allCases.map(\.rawValue),
            selection: categorySelection
        ) { _ in EmptyView() }
        .baziBackground(.bgWhite)
    }

    private var emptyView: some View {
        VStack(spacing: 20) {
            BZEmptyView(message: "아직 찜한 정책이 없어요")
            BZButton("찜할 정책 둘러보러 가기", type: .normal2, size: .medium) {
                store.send(.didTapBrowsePolicies)
            }
            .padding(.horizontal, 60)
        }
    }

    private var resultsToolbar: some View {
        BZResultsToolbar(count: store.visibleTotalCount, sortTitle: store.sortOrder.title) {
            store.send(.didTapSortOrder)
        }
    }

    private func policyList(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(policies) { policy in
                BZCard(
                    size: .medium,
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
        .padding(.top, 8)
        .padding([.horizontal, .bottom], 20)
    }
}

// MARK: - Bindings

extension MyPolicyListView {

    private var categorySelection: Binding<String> {
        Binding(
            get: { store.selectedCategory?.rawValue ?? Self.allCategoryTitle },
            set: { newValue in
                // "전체"는 PolicyCategoryUI에 없어 rawValue 변환이 nil → 전체(필터 해제)로 처리된다.
                store.send(.didSelectCategory(PolicyCategoryUI(rawValue: newValue)))
            }
        )
    }

    private func likeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.list.value?[id: id]?.isLiked ?? false },
            set: { _ in store.send(.didToggleLike(id: id)) }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MyPolicyListView(
            store: Store(initialState: .init()) {
                MyPolicyListFeature()
            }
        )
    }
}
