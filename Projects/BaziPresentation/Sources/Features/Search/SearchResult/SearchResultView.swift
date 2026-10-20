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
            resultsArea
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
            .accessibilityLabel("뒤로 가기")

            // 결과 화면에서는 직접 편집하지 않고, 검색바를 탭하면 뒤로가기와 동일하게 검색 입력 화면으로 돌아간다.
            // 필드 자체는 히트테스트를 끄고, 투명 오버레이가 탭을 받아 전체 영역을 탭 가능하게 한다.
            BZSearchField(text: .constant(store.query))
                .disabled(true)
                .allowsHitTesting(false)
                .overlay {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("검색어 \(store.query)")
                .accessibilityHint("두 번 탭하면 검색 화면으로 돌아갑니다")
                .accessibilityAddTraits(.isButton)
                .accessibilityAction { dismiss() }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .baziBackground(.bgGray)
    }

    private static let allCategoryTitle = "전체"

    private var categoryFilter: some View {
        BZSegmentControl(
            options: [Self.allCategoryTitle] + PolicyCategoryUI.allCases.map(\.rawValue),
            selection: categorySelection
        ) { _ in EmptyView() }
        .baziBackground(.bgGray)
    }

    private var resultsToolbar: some View {
        BZResultsToolbar(count: store.pagination.totalCount, sortTitle: store.sortOrder.rawValue) {
            store.send(.didTapSortOrder)
        }
    }

    @ViewBuilder
    private var resultsArea: some View {
        switch store.results {
        case .idle, .loading:
            BZLoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .failed(message):
            BZRetryView(message: message) { store.send(.didTapRetry) }
        case .loaded(let policies):
            if policies.isEmpty {
                BZEmptyView(message: "검색 결과가 없어요")
                    .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    resultList(policies)
                }
                .refreshable { await store.send(.pullToRefresh).finish() }
            }
        }
    }

    private func resultList(_ policies: IdentifiedArrayOf<PolicySummaryVO>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(policies) { policy in
                BZCard(
                    size: .medium,
                    category: policy.category.rawValue,
                    dDay: policy.dDay,
                    title: policy.title,
                    viewCount: policy.viewCount,
                    isLiked: likeBinding(id: policy.id),
                    onOpen: { store.send(.didTapPolicy(id: policy.id)) }
                )
                .onAppear {
                    if policy.id == policies.last?.id {
                        store.send(.didReachListEnd)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

// MARK: - Bindings

extension SearchResultView {

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
            get: { store.likeOverrides[id] ?? (store.results.value?[id: id]?.isLiked ?? false) },
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
