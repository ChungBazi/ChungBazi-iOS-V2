// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

@Reducer
public struct SearchFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case searchResult(SearchResultFeature)
        case detail(PolicyDetailFeature)
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public var query: String
        public var recentKeywords: IdentifiedArrayOf<RecentSearchKeyword>
        public var isAutoSaveEnabled: Bool
        public var suggestions: [SearchSuggestion]

        public var isTyping: Bool { !query.isEmpty }

        public init() {
            self.query = ""
            self.recentKeywords = []
            self.isAutoSaveEnabled = true
            self.suggestions = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didChangeQuery(String)
        case didSubmitQuery
        case didTapSuggestion(String)
        case didTapDeleteRecentKeyword(id: Int)
        case didTapDeleteAllRecentKeywords
        case didToggleAutoSave

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 검색 UseCase가 준비되면 추가
    // @Dependency(\.policySearchClient) var policySearchClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: policySearchClient가 준비되면 RecentSearchAPI 응답으로 교체한다.
                state.recentKeywords = IdentifiedArray(uniqueElements: RecentSearchKeyword.mockList)
                return .none

            case .didChangeQuery(let query):
                state.query = query
                state.suggestions = SearchSuggestion.suggestions(
                    for: query,
                    recentKeywords: state.recentKeywords.map(\.keyword)
                )
                return .none

            case .didSubmitQuery:
                guard !state.query.isEmpty else { return .none }
                return submitSearch(state: &state, query: state.query)

            case .didTapSuggestion(let keyword):
                return submitSearch(state: &state, query: keyword)

            case .didTapDeleteRecentKeyword(let id):
                state.recentKeywords.remove(id: id)
                return .none

            case .didTapDeleteAllRecentKeywords:
                state.recentKeywords.removeAll()
                return .none

            case .didToggleAutoSave:
                state.isAutoSaveEnabled.toggle()
                return .none

            case .path(.element(_, .searchResult(.delegate(.didSelectPolicy(let id))))),
                 .path(.element(_, .detail(.delegate(.didSelectPolicy(let id))))):
                state.path.append(.detail(PolicyDetailFeature.State(policyId: id)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    private func submitSearch(state: inout State, query: String) -> Effect<Action> {
        state.query = query
        state.suggestions = []
        if state.isAutoSaveEnabled, !state.recentKeywords.contains(where: { $0.keyword == query }) {
            let nextID = (state.recentKeywords.map(\.id).max() ?? 0) + 1
            state.recentKeywords.insert(RecentSearchKeyword(id: nextID, keyword: query), at: 0)
        }
        state.path.append(.searchResult(SearchResultFeature.State(query: query)))
        return .none
    }
}

extension SearchFeature.Path.State: Equatable {}
