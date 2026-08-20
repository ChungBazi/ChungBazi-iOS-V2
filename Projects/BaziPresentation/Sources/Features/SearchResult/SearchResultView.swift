// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct SearchResultView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<SearchResultFeature>
    @Environment(\.dismiss) private var dismiss

    // MARK: - Init

    public init(store: StoreOf<SearchResultFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Subviews

extension SearchResultView {

    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                categoryFilter
                resultsToolbar
                resultList
            }
        }
        .baziBackground(.bgGray)
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Color.gray900)
            }
            .buttonStyle(.plain)

            // 검색어 편집은 이전 화면에서만 하고, 결과 화면에서는 뒤로가기로만 돌아갈 수 있어 인터랙션을 막는다.
            BZSearchField(text: .constant(store.query))
                .disabled(true)
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
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
        .baziBackground(.bgGray)
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
            Text("\(store.results.count)개")
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

    private var resultList: some View {
        LazyVStack(spacing: 12) {
            ForEach(store.results) { policy in
                BZCard(
                    size: .medium,
                    category: policy.category.rawValue,
                    dDay: policy.dDay,
                    title: policy.title,
                    viewCount: policy.viewCount,
                    isBookmarked: bookmarkBinding(id: policy.id)
                )
                .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Bindings

extension SearchResultView {

    private func bookmarkBinding(id: Int) -> Binding<Bool> {
        Binding(
            get: { store.results[id: id]?.isBookmarked ?? false },
            set: { _ in store.send(.didToggleBookmark(id: id)) }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SearchResultView(
            store: Store(initialState: .init(query: "청년 일자리")) {
                SearchResultFeature()
            }
        )
    }
}
