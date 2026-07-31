// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct AppFeature {

    // MARK: - State

    @ObservableState
    public enum State: Equatable {
        case splash(SplashFeature.State)
        case login(LoginFeature.State)
        case nicknameSetup(NicknameSetupFeature.State)
        case onboarding(OnboardingFeature.State)
        case main(MainFeature.State)
    }

    // MARK: - Action

    public enum Action {
        // MARK: Child
        case splash(SplashFeature.Action)
        case login(LoginFeature.Action)
        case nicknameSetup(NicknameSetupFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case main(MainFeature.Action)
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .splash(.delegate(.didFinishSplash(let hasValidToken, let hasNickname, let hasCompletedOnboarding))):
                state = Self.resolveRoot(
                    hasValidToken: hasValidToken,
                    hasNickname: hasNickname,
                    hasCompletedOnboarding: hasCompletedOnboarding
                )
                return .none

            case .splash:
                return .none

            case .login(.delegate(.didLogin(let hasNickname, let hasCompletedOnboarding))):
                // 로그인 완료 후 다음 화면은 항상 새로 시작하는 root — push가 아니라 state 교체.
                state = Self.resolveRoot(
                    hasValidToken: true,
                    hasNickname: hasNickname,
                    hasCompletedOnboarding: hasCompletedOnboarding
                )
                return .none

            case .login:
                return .none

            case .nicknameSetup(.delegate(.didSetNickname)):
                state = .onboarding(OnboardingFeature.State())
                return .none

            case .nicknameSetup:
                return .none

            case .onboarding(.delegate(.didCompleteOnboarding)):
                state = .main(MainFeature.State())
                return .none

            case .onboarding:
                return .none

            case .main(.delegate(.didLogout)):
                state = .login(LoginFeature.State())
                return .none

            case .main:
                return .none
            }
        }
        .ifCaseLet(\.splash, action: \.splash) {
            SplashFeature()
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifCaseLet(\.nicknameSetup, action: \.nicknameSetup) {
            NicknameSetupFeature()
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        .ifCaseLet(\.main, action: \.main) {
            MainFeature()
        }
    }
}

// MARK: - Root 분기 규칙

extension AppFeature {

    /// 자동로그인 O + 닉네임 O + 온보딩 O → 홈
    /// 자동로그인 X → 로그인
    /// 자동로그인 O + 닉네임 X → 닉네임 설정
    /// 자동로그인 O + 닉네임 O + 온보딩 X → 온보딩
    /// (로그인 완료 직후에도 hasValidToken: true로 동일 함수를 재사용해 같은 규칙을 적용한다)
    static func resolveRoot(
        hasValidToken: Bool,
        hasNickname: Bool,
        hasCompletedOnboarding: Bool
    ) -> State {
        guard hasValidToken else { return .login(LoginFeature.State()) }
        guard hasNickname else { return .nicknameSetup(NicknameSetupFeature.State()) }
        guard hasCompletedOnboarding else { return .onboarding(OnboardingFeature.State()) }
        return .main(MainFeature.State())
    }
}
