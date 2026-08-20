// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 홈 "인기/마감임박/새로 뜬 정책"의 더보기 화면. 세 섹션이 레이아웃을 공유하므로
/// `Kind`로만 문구·정렬 기준을 구분한다 (14/15/16번 화면).
@Reducer
public struct RankedPolicyListFeature {

    // MARK: - Kind

    public enum Kind: Equatable {
        case popular
        case deadline
        case latest

        public var navigationTitle: String {
            switch self {
            case .popular: return "인기 정책"
            case .deadline: return "마감 임박 정책"
            case .latest: return "새로 뜬 정책"
            }
        }

        public var bannerTitle: String {
            switch self {
            case .popular: return "가장 인기 있는 정책을 모아봤어요!"
            case .deadline: return "곧 마감되는 정책을 놓치지 마세요!"
            case .latest: return "따끈한 정책을 먼저 확인해봐요!"
            }
        }

        /// 순위 배지는 인기 정책에서만 보여준다.
        public var showsRankBadge: Bool { self == .popular }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let kind: Kind
        public var teaserPolicies: IdentifiedArrayOf<PolicySummary>
        public var selectedCategory: PolicyCategory
        public var policies: IdentifiedArrayOf<PolicySummary>

        public init(kind: Kind, selectedCategory: PolicyCategory = .job) {
            self.kind = kind
            self.teaserPolicies = []
            self.selectedCategory = selectedCategory
            self.policies = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didSelectCategory(PolicyCategory)
        case didToggleTeaserBookmark(id: Int)
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

    // TODO: BaziDomain의 정책 UseCase가 준비되면 추가
    // @Dependency(\.policyClient) var policyClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.teaserPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
                state.policies = policies(for: state.selectedCategory)
                return .none

            case .didSelectCategory(let category):
                state.selectedCategory = category
                state.policies = policies(for: category)
                return .none

            case .didToggleTeaserBookmark(let id):
                state.teaserPolicies[id: id]?.isBookmarked.toggle()
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

    private func policies(for category: PolicyCategory) -> IdentifiedArrayOf<PolicySummary> {
        IdentifiedArray(uniqueElements: PolicySummary.mockList.filter { $0.category == category })
    }
}
