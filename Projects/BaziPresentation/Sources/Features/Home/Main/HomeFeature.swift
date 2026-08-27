// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

@Reducer
public struct HomeFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case categoryPolicyList(CategoryPolicyListFeature)
        case rankedPolicyList(RankedPolicyListFeature)
        case customPolicyList(CustomPolicyListFeature)
        case detail(PlaceholderDetailFeature)
    }

    // MARK: - PolicySection

    /// 홈 화면에서 북마크 토글이 어느 섹션의 배열을 바꿔야 하는지 구분한다.
    public enum PolicySection: Equatable {
        case personalized
        case recentViewed
        case popular
        case deadline
        case newest
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public var userName: String
        public var personalizedPolicies: IdentifiedArrayOf<PolicySummary>
        public var recentViewedPolicies: IdentifiedArrayOf<PolicySummary>
        public var popularPolicies: IdentifiedArrayOf<PolicySummary>
        public var deadlinePolicies: IdentifiedArrayOf<PolicySummary>
        public var newPolicies: IdentifiedArrayOf<PolicySummary>

        public init() {
            self.userName = "민재"
            self.personalizedPolicies = []
            self.recentViewedPolicies = []
            self.popularPolicies = []
            self.deadlinePolicies = []
            self.newPolicies = []
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapBell
        case didTapCategory(PolicyCategory)
        case didTapPersonalizedMore
        case didTapPersonalizedEmptyCTA
        case didTapPopularMore
        case didTapDeadlineMore
        case didTapNewMore
        case didTapPolicy(section: PolicySection, id: Int)
        case didToggleBookmark(section: PolicySection, id: Int)

        // MARK: Child
        case path(StackActionOf<Path>)
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
                // TODO: policyClient가 준비되면 HomeAPI.getHomePolicySection 응답으로 교체한다.
                state.personalizedPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
                state.recentViewedPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.suffix(2)))
                state.popularPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.prefix(2)))
                state.deadlinePolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.dropFirst(2).prefix(2)))
                state.newPolicies = IdentifiedArray(uniqueElements: Array(PolicySummary.mockList.dropFirst(4).prefix(2)))
                return .none

            case .didTapBell:
                // TODO: 알림 Feature가 준비되면 연결한다.
                return .none

            case .didTapCategory(let category):
                state.path.append(.categoryPolicyList(CategoryPolicyListFeature.State(selectedCategory: category)))
                return .none

            case .didTapPersonalizedMore:
                state.path.append(.customPolicyList(CustomPolicyListFeature.State(userName: state.userName)))
                return .none

            case .didTapPersonalizedEmptyCTA:
                // TODO: SharedRoute.policyRecommendationEdit(맞춤 조건 다시 설정) Feature가 준비되면 연결한다.
                return .none

            case .didTapPopularMore:
                state.path.append(.rankedPolicyList(RankedPolicyListFeature.State(kind: .popular)))
                return .none

            case .didTapDeadlineMore:
                state.path.append(.rankedPolicyList(RankedPolicyListFeature.State(kind: .deadline)))
                return .none

            case .didTapNewMore:
                state.path.append(.rankedPolicyList(RankedPolicyListFeature.State(kind: .latest)))
                return .none

            case .didTapPolicy:
                state.path.append(.detail(PlaceholderDetailFeature.State(id: UUID())))
                return .none

            case .didToggleBookmark(let section, let id):
                toggleBookmark(section: section, id: id, state: &state)
                return .none

            case .path(.element(_, .categoryPolicyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .rankedPolicyList(.delegate(.didSelectPolicy)))),
                 .path(.element(_, .customPolicyList(.delegate(.didSelectPolicy)))):
                state.path.append(.detail(PlaceholderDetailFeature.State(id: UUID())))
                return .none

            case let .path(.element(_, .categoryPolicyList(.delegate(.didTapPersonalizedMore(category))))):
                state.path.append(.customPolicyList(CustomPolicyListFeature.State(userName: state.userName, category: category)))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

    // MARK: - Private

    private func toggleBookmark(section: PolicySection, id: Int, state: inout State) {
        switch section {
        case .personalized: state.personalizedPolicies[id: id]?.isBookmarked.toggle()
        case .recentViewed: state.recentViewedPolicies[id: id]?.isBookmarked.toggle()
        case .popular: state.popularPolicies[id: id]?.isBookmarked.toggle()
        case .deadline: state.deadlinePolicies[id: id]?.isBookmarked.toggle()
        case .newest: state.newPolicies[id: id]?.isBookmarked.toggle()
        }
    }
}

extension HomeFeature.Path.State: Equatable {}
