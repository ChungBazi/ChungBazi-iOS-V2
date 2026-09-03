// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziDesign
import ComposableArchitecture

public struct SearchView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<SearchFeature>

    // MARK: - Init

    public init(store: StoreOf<SearchFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            content
                .task { store.send(.onAppear) }
        } destination: { store in
            switch store.case {
            case .searchResult(let store):
                SearchResultView(store: store)
            case .detail(let store):
                PolicyDetailView(store: store)
            }
        }
    }
}

// MARK: - Subviews

extension SearchView {

    private var content: some View {
        VStack(spacing: 0) {
            searchField
            if store.isTyping {
                suggestionList
            } else {
                ScrollView {
                    recentSearchSection
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
        .baziBackground(.bgGray)
    }

    private var searchField: some View {
        BZSearchField(
            text: Binding(
                get: { store.query },
                set: { store.send(.didChangeQuery($0)) }
            ),
            onSubmit: { store.send(.didSubmitQuery) }
        )
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
    }
}

// MARK: - Recent Search

extension SearchView {

    private var recentSearchSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            recentSearchHeader
            if store.isAutoSaveEnabled, !store.recentKeywords.isEmpty {
                recentSearchList
            }
            autoSaveToggle
        }
        .padding(20)
    }

    private var recentSearchHeader: some View {
        HStack {
            Text("최근 검색어")
                .baziFont(.small14SB)
                .foregroundStyle(Color.gray900)
            Spacer()
            if store.isAutoSaveEnabled, !store.recentKeywords.isEmpty {
                Button("전체삭제") {
                    store.send(.didTapDeleteAllRecentKeywords)
                }
                .buttonStyle(.plain)
                .baziFont(.small14R)
                .foregroundStyle(Color.gray500)
            }
        }
    }

    private var recentSearchList: some View {
        VStack(spacing: 0) {
            ForEach(store.recentKeywords) { keyword in
                recentSearchRow(keyword)
            }
        }
    }

    private func recentSearchRow(_ keyword: RecentSearchKeywordVO) -> some View {
        HStack {
            Button {
                store.send(.didTapSuggestion(keyword.keyword))
            } label: {
                HStack(spacing: 8) {
                    Image.bazi(.historyIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16)
                        .foregroundStyle(Color.gray500)
                    Text(keyword.keyword)
                        .baziFont(.small14R)
                        .foregroundStyle(Color.gray700)
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                store.send(.didTapDeleteRecentKeyword(id: keyword.id))
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.gray500)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("검색 기록 삭제")
        }
        .frame(height: 48)
    }

    private var autoSaveToggle: some View {
        HStack(spacing: 8) {
            Toggle("", isOn: Binding(
                get: { store.isAutoSaveEnabled },
                set: { _ in store.send(.didToggleAutoSave) }
            ))
            .labelsHidden()
            .tint(Color.bazi(.primary))
            .accessibilityLabel("검색어 자동저장")

            Text("자동저장")
                .baziFont(.small14R)
                .foregroundStyle(Color.gray800)
        }
    }
}

// MARK: - Suggestions

extension SearchView {

    private var suggestionList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(store.suggestions) { suggestion in
                    suggestionRow(suggestion)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .scrollDismissesKeyboard(.immediately)
    }

    private func suggestionRow(_ suggestion: SearchSuggestionVO) -> some View {
        Button {
            store.send(.didTapSuggestion(suggestion.keyword))
        } label: {
            HStack {
                highlightedSuggestionText(suggestion.keyword)
                Spacer()
                if suggestion.isFromHistory {
                    Image.bazi(.historyIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16)
                }
            }
            .frame(height: 48)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func highlightedSuggestionText(_ keyword: String) -> Text {
        guard let range = keyword.range(of: store.query, options: .caseInsensitive) else {
            return Text(keyword)
                .font(BaziFont.small14R.font)
                .foregroundColor(Color.gray700)
        }
        let prefix = Text(keyword[..<range.lowerBound])
            .font(BaziFont.small14R.font)
            .foregroundColor(Color.gray700)
        let matched = Text(keyword[range])
            .font(BaziFont.small14SB.font)
            .foregroundColor(Color.bazi(.primary))
        let rest = Text(keyword[range.upperBound...])
            .font(BaziFont.small14R.font)
            .foregroundColor(Color.gray700)
        return prefix + matched + rest
    }
}

// MARK: - Preview

#Preview("최근 검색어") {
    SearchView(
        store: Store(initialState: .init()) {
            SearchFeature()
        }
    )
}

#Preview("최근 검색어 없음") {
    var state = SearchFeature.State()
    state.recentKeywords = []
    state.isAutoSaveEnabled = false

    return SearchView(
        store: Store(initialState: state) {
            EmptyReducer()
        }
    )
}

#Preview("입력 중") {
    var state = SearchFeature.State()
    state.query = "청년 일자리"
    state.recentKeywords = RecentSearchResultVO.mock.keywords
    state.suggestions = SearchSuggestionVO.mockList

    return SearchView(
        store: Store(initialState: state) {
            EmptyReducer()
        }
    )
}
