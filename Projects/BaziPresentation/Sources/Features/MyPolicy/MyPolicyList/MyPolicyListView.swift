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
    }
}

// MARK: - Subviews

extension MyPolicyListView {

    private var content: some View {
        // 카테고리 필터 + 결과 툴바(갯수/정렬)까지는 상단 고정, 그 아래 정책 리스트만 스크롤한다.
        VStack(spacing: 0) {
            categoryFilter
            if store.policies.isEmpty {
                emptyView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                resultsToolbar
                ScrollView {
                    policyList
                }
            }
        }
        .baziBackground(.bgGray)
    }

    private static let allCategoryTitle = "전체"

    private var categoryFilter: some View {
        BZSegmentControl(
            options: [Self.allCategoryTitle] + PolicyCategory.allCases.map(\.rawValue),
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
            .padding(.horizontal, 20)
        }
    }

    private var resultsToolbar: some View {
        BZResultsToolbar(count: store.policies.count, sortTitle: store.sortOrder.title) {
            store.send(.didTapSortOrder)
        }
    }

    private var policyList: some View {
        LazyVStack(spacing: 12) {
            ForEach(store.policies) { policy in
                BZCard(
                    size: .medium,
                    category: policy.category.rawValue,
                    dDay: policy.dDay,
                    title: policy.title,
                    viewCount: policy.viewCount,
                    isLiked: likeBinding(id: policy.id)
                )
                .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
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
                // "전체"는 PolicyCategory에 없어 rawValue 변환이 nil → 전체(필터 해제)로 처리된다.
                store.send(.didSelectCategory(PolicyCategory(rawValue: newValue)))
            }
        )
    }

    private func likeBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.policies[id: id]?.isLiked ?? false },
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
