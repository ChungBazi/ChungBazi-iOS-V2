// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 홈 "분야별 정책" 더보기 화면 (13-1). 분야 탭 전환 + 맞춤 정책 배너 + 정렬 가능한 목록으로 구성된다.
@Reducer
public struct CategoryPolicyListFeature {

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable {
        case deadline = "마감순"
        case latest = "최신순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedCategory: PolicyCategory
        public var personalizedTeaser: IdentifiedArrayOf<PolicySummary>
        public var sortOrder: SortOrder
        public var policies: IdentifiedArrayOf<PolicySummary>

        public init(selectedCategory: PolicyCategory) {
            self.selectedCategory = selectedCategory
            self.personalizedTeaser = []
            self.sortOrder = .deadline
            self.policies = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didSelectCategory(PolicyCategory)
        case didTapSortOrder
        case didTapPersonalizedMore
        case didToggleTeaserBookmark(id: Int)
        case didToggleBookmark(id: Int)
        case didTapPolicy(id: Int)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
        case didTapPersonalizedMore(PolicyCategory)
    }

    // MARK: - Dependencies

    // TODO: 이 Feature가 쓸 Client가 준비되면 추가
    // @Dependency(\.someClient) var someClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.personalizedTeaser = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
                state.policies = policies(for: state.selectedCategory, sortOrder: state.sortOrder)
                return .none

            case .didSelectCategory(let category):
                state.selectedCategory = category
                state.policies = policies(for: category, sortOrder: state.sortOrder)
                return .none

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                state.policies = policies(for: state.selectedCategory, sortOrder: state.sortOrder)
                return .none

            case .didTapPersonalizedMore:
                return .send(.delegate(.didTapPersonalizedMore(state.selectedCategory)))

            case .didToggleTeaserBookmark(let id):
                state.personalizedTeaser[id: id]?.isBookmarked.toggle()
                return .none

            case .didToggleBookmark(let id):
                state.policies[id: id]?.isBookmarked.toggle()
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private func policies(for category: PolicyCategory, sortOrder: SortOrder) -> IdentifiedArrayOf<PolicySummary> {
        let filtered = PolicySummary.mockList.filter { $0.category == category }
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
