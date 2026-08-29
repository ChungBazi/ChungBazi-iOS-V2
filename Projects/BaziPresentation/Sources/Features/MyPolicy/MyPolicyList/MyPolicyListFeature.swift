// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 내 정책 전체보기 화면 (20). 분야 필터 + 정렬 + 찜한 정책 전체 목록으로 구성된다.
@Reducer
public struct MyPolicyListFeature {

    // MARK: - SortOrder

    public enum SortOrder: Equatable {
        case deadline
        case latest

        var title: String {
            switch self {
            case .deadline: return "마감순"
            case .latest: return "최신순"
            }
        }

        var next: SortOrder { self == .deadline ? .latest : .deadline }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedCategory: PolicyCategory?
        public var sortOrder: SortOrder
        /// 원본 목록(찜 상태 보유). 서버 응답으로 교체될 값. 필터/정렬은 파생(`policies`)으로 계산한다.
        public var allPolicies: IdentifiedArrayOf<PolicySummary>

        /// 파생: 카테고리 필터 + 정렬 적용 결과.
        public var policies: IdentifiedArrayOf<PolicySummary> {
            let filtered = allPolicies.filter { selectedCategory == nil || $0.category == selectedCategory }
            let sorted = sortOrder == .deadline
                ? filtered.sorted { $0.deadlineDate < $1.deadlineDate }
                : filtered.sorted { $0.id > $1.id }
            return IdentifiedArray(uniqueElements: sorted)
        }

        public init() {
            self.selectedCategory = nil
            self.sortOrder = .deadline
            self.allPolicies = []
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didSelectCategory(PolicyCategory?)
        case didTapSortOrder
        case didToggleLike(id: Int)
        case didTapPolicy(id: Int)
        case didTapBrowsePolicies

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
                // TODO: myPolicyClient가 준비되면 MyPolicyAPI 응답으로 교체한다.
                if state.allPolicies.isEmpty {
                    state.allPolicies = IdentifiedArray(uniqueElements: PolicySummary.mockList)
                }
                return .none

            case .didSelectCategory(let category):
                state.selectedCategory = category
                return .none

            case .didTapSortOrder:
                state.sortOrder = state.sortOrder.next
                return .none

            case .didToggleLike(let id):
                state.allPolicies[id: id]?.isLiked.toggle()
                return .none

            case .didTapPolicy(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .didTapBrowsePolicies:
                // TODO: 정책 둘러보기(홈/검색 등)로 이동 연결.
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
