// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 내 정책 전체보기 화면 (20). 분야 필터 + 정렬 + 찜한 정책 전체 목록으로 구성된다.
@Reducer
public struct MyPolicyListFeature {

    // MARK: - SortOrder

    public enum SortOrder: String, Equatable {
        case deadline = "마감순"
        case latest = "최신순"

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedCategory: PolicyCategory?
        public var sortOrder: SortOrder
        public var policies: IdentifiedArrayOf<PolicySummary>

        public init() {
            self.selectedCategory = nil
            self.sortOrder = .deadline
            self.policies = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didSelectCategory(PolicyCategory?)
        case didTapSortOrder
        case didToggleLike(id: Int)
        case didTapPolicy(id: Int)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 추가
    // @Dependency(\.myPolicyClient) var myPolicyClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
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

            case .didToggleLike(let id):
                state.policies[id: id]?.isLiked.toggle()
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    private func policies(for category: PolicyCategory?, sortOrder: SortOrder) -> IdentifiedArrayOf<PolicySummary> {
        let filtered = PolicySummary.mockList.filter { category == nil || $0.category == category }
        let sorted = sortOrder == .deadline
            ? filtered.sorted { $0.deadlineDate < $1.deadlineDate }
            : filtered.sorted { $0.id > $1.id }
        return IdentifiedArray(uniqueElements: sorted)
    }
}
