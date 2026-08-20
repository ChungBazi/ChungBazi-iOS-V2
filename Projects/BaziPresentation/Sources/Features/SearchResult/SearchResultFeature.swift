// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 검색 결과 화면 (17-4). 분야 필터 + 정렬 + 결과 목록으로 구성된다.
@Reducer
public struct SearchResultFeature {

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable {
        case deadline = "마감순"
        case latest = "최신순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var query: String
        public var selectedCategory: PolicyCategory?
        public var sortOrder: SortOrder
        public var results: IdentifiedArrayOf<PolicySummary>

        public init(query: String) {
            self.query = query
            self.selectedCategory = nil
            self.sortOrder = .deadline
            self.results = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didSelectCategory(PolicyCategory?)
        case didTapSortOrder
        case didToggleBookmark(id: Int)
        case didTapPolicy(id: Int)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
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
                state.results = results(query: state.query, category: state.selectedCategory, sortOrder: state.sortOrder)
                return .none

            case .didSelectCategory(let category):
                state.selectedCategory = category
                state.results = results(query: state.query, category: category, sortOrder: state.sortOrder)
                return .none

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                state.results = results(query: state.query, category: state.selectedCategory, sortOrder: state.sortOrder)
                return .none

            case .didToggleBookmark(let id):
                state.results[id: id]?.isBookmarked.toggle()
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private func results(
        query: String,
        category: PolicyCategory?,
        sortOrder: SortOrder
    ) -> IdentifiedArrayOf<PolicySummary> {
        let filtered = PolicySummary.mockList.filter { policy in
            let matchesQuery = query.isEmpty || policy.title.contains(query)
            let matchesCategory = category == nil || policy.category == category
            return matchesQuery && matchesCategory
        }
        let sorted = sortOrder == .deadline
            ? filtered.sorted { $0.dDay.dDayValue < $1.dDay.dDayValue }
            : filtered.sorted { $0.id > $1.id }
        return IdentifiedArray(uniqueElements: sorted)
    }
}

// MARK: - DDay Sorting

extension String {
    /// "D-11" → 11. 정렬 전용 값으로 파싱 실패 시 가장 마지막 순위로 취급한다.
    fileprivate var dDayValue: Int {
        Int(dropFirst(2)) ?? .max
    }
}
