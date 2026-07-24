// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct LoginFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case didTapLoginButton

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        /// 로그인 성공 후 다음 root를 정하기 위해 필요한 사용자 상태.
        case didLogin(hasNickname: Bool, hasCompletedOnboarding: Bool)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 인증 UseCase가 준비되면 추가
    // @Dependency(\.authClient) var authClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapLoginButton:
                // TODO: authClient가 준비되면 실제 로그인 요청으로 교체.
                // 로그인 응답에 닉네임/온보딩 완료 여부가 함께 내려온다고 가정.
                return .send(.delegate(.didLogin(hasNickname: false, hasCompletedOnboarding: false)))

            case .delegate:
                return .none
            }
        }
    }
}
