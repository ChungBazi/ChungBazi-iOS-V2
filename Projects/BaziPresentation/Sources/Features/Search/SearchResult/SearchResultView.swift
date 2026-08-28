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
        VStack(spacing: 0) {
            header
            categoryFilter
            resultsToolbar
            ScrollView {
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
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color.gray900)
            }
            .buttonStyle(.plain)

            // 검색어 편집은 이전 화면에서만 하고, 결과 화면에서는 뒤로가기로만 돌아갈 수 있어 인터랙션을 막는다.
            BZSearchField(text: .constant(store.query))
                .disabled(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .baziBackground(.bgGray)
    }

    private static let allCategoryTitle = "전체"

    private var categoryFilter: some View {
        BZSegmentControl(
            options: [Self.allCategoryTitle] + PolicyCategory.allCases.map(\.rawValue),
            selection: categorySelection
        ) { _ in EmptyView() }
        .baziBackground(.bgGray)
    }

    private var resultsToolbar: some View {
        HStack {
            Text("\(store.results.count)개")
            Spacer()
            Button {
                store.send(.didTapSortOrder)
            } label: {
                HStack(spacing: 3) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(store.sortOrder.rawValue)
                }
            }
            .buttonStyle(.plain)
        }
        .baziFont(.small14R)
        .foregroundStyle(Color.gray600)
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
                    isLiked: likeBinding(id: policy.id)
                )
                .onTapGesture { store.send(.didTapPolicy(id: policy.id)) }
            }
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Bindings

extension SearchResultView {

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
            get: { store.results[id: id]?.isLiked ?? false },
            set: { _ in store.send(.didToggleLike(id: id)) }
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
