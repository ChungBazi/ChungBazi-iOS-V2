// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct MainFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var selectedTab: MainTab = .home
        public var home = HomeFeature.State()
        public var search = SearchFeature.State()
        public var myPolicy = MyPolicyFeature.State()
        public var profile = ProfileFeature.State()

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case didSelectTab(MainTab)

        // MARK: Child
        case home(HomeFeature.Action)
        case search(SearchFeature.Action)
        case myPolicy(MyPolicyFeature.Action)
        case profile(ProfileFeature.Action)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didLogout
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didSelectTab(let tab):
                state.selectedTab = tab
                // 내 정책 탭 진입 시, 다른 화면에서 바뀐 찜 상태(신규 찜 포함)를 반영하도록 갱신을 트리거한다.
                return tab == .myPolicy ? .send(.myPolicy(.onAppear)) : .none

            case .profile(.delegate(.didLogout)):
                return .send(.delegate(.didLogout))

            case .home, .search, .myPolicy, .profile, .delegate:
                return .none
            }
        }
        Scope(state: \.home, action: \.home) { HomeFeature() }
        Scope(state: \.search, action: \.search) { SearchFeature() }
        Scope(state: \.myPolicy, action: \.myPolicy) { MyPolicyFeature() }
        Scope(state: \.profile, action: \.profile) { ProfileFeature() }
    }
}
