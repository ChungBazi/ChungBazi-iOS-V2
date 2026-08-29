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
        ScrollView {
            VStack(spacing: 0) {
                categoryFilter
                resultsToolbar
                policyList
            }
        }
        .baziBackground(.bgGray)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                categoryFilterItem(title: "전체", isSelected: store.selectedCategory == nil) {
                    store.send(.didSelectCategory(nil))
                }
                ForEach(PolicyCategory.allCases) { category in
                    categoryFilterItem(title: category.rawValue, isSelected: store.selectedCategory == category) {
                        store.send(.didSelectCategory(category))
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 44)
        .baziBackground(.bgWhite)
    }

    private func categoryFilterItem(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .baziFont(isSelected ? .small14SB : .small14R)
                .foregroundStyle(isSelected ? Color.grayBlack : Color.gray300)
        }
        .buttonStyle(.plain)
    }

    private var resultsToolbar: some View {
        HStack {
            Text("\(store.policies.count)개")
                .baziFont(.small14R)
                .foregroundStyle(Color.gray600)
            Spacer()
            Button {
                store.send(.didTapSortOrder)
            } label: {
                Label(store.sortOrder.rawValue, systemImage: "arrow.up.arrow.down")
                    .labelStyle(.titleAndIcon)
            }
            .buttonStyle(.plain)
            .baziFont(.small14R)
            .foregroundStyle(Color.gray600)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
        .padding(.horizontal, 16)
    }
}

// MARK: - Bindings

extension MyPolicyListView {

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
