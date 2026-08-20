// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 홈 "맞춤정책 더보기" 화면 (12-4). 뒤집기 카드 캐러셀 + 최초 진입 시 2단계 가이드 오버레이로 구성된다.
@Reducer
public struct CustomPolicyListFeature {

    // MARK: - GuideStep

    public enum GuideStep: Equatable {
        case swipeHint
        case tapHint

        var next: GuideStep? { self == .swipeHint ? .tapHint : nil }
        var illustration: String { self == .swipeHint ? "arrow.left.and.right" : "hand.tap" }
        var message: String {
            self == .swipeHint
                ? "카드를 좌우로 넘기며\n맞춤 정책을 살펴보세요!"
                : "카드를 눌러 간편하게\n정책 정보를 확인해보세요!"
        }
        var buttonTitle: String { self == .swipeHint ? "다음" : "확인" }
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var userName: String
        public var policies: IdentifiedArrayOf<PersonalizedPolicy>
        public var guideStep: GuideStep?

        public init(userName: String = "민재") {
            self.userName = userName
            self.policies = []
            self.guideStep = .swipeHint
        }
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didToggleBookmark(id: Int)
        case didTapDetail(id: Int)
        case didTapGuideNext

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSelectPolicy(id: Int)
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
                state.policies = IdentifiedArray(uniqueElements: PersonalizedPolicy.mockList)
                return .none

            case .didToggleBookmark(let id):
                state.policies[id: id]?.isBookmarked.toggle()
                return .none

            case .didTapDetail(let id):
                return .send(.delegate(.didSelectPolicy(id: id)))

            case .didTapGuideNext:
                state.guideStep = state.guideStep?.next
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
