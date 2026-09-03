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
        case onboarding(OnboardingStartFeature.State)
        case main(MainFeature.State)
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case task
        case forceLoggedOut
        case deeplink(Deeplink)

        // MARK: Child
        case splash(SplashFeature.Action)
        case login(LoginFeature.Action)
        case nicknameSetup(NicknameSetupFeature.Action)
        case onboarding(OnboardingStartFeature.Action)
        case main(MainFeature.Action)
    }

    // MARK: - Dependencies

    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.deeplinkClient) var deeplinkClient
    @Dependency(\.analytics) var analytics

    private enum CancelID { case forceLogout, deeplink }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .task:
                // 런타임 강제 로그아웃(.forceLogout) + 딥링크(카카오/푸시) 구독
                return .merge(
                    .run { [sessionClient] send in
                        for await _ in sessionClient.forceLogoutEvents() {
                            await send(.forceLoggedOut)
                        }
                    }
                    .cancellable(id: CancelID.forceLogout, cancelInFlight: true),
                    .run { [deeplinkClient] send in
                        for await link in deeplinkClient.events() {
                            await send(.deeplink(link))
                        }
                    }
                    .cancellable(id: CancelID.deeplink, cancelInFlight: true)
                )

            case .deeplink(let link):
                // main이면 즉시 라우팅하고 버퍼를 비운다. 아직 main이 아니면(콜드런치 등) 버퍼에 남겨두고
                // main 진입 시점(splash/login/onboarding → main)에 flush한다.
                guard case .main(var mainState) = state else { return .none }
                apply(link, to: &mainState)
                state = .main(mainState)
                _ = deeplinkClient.takePending()
                return .none

            case .forceLoggedOut:
                if case .login = state { return .none } // 이미 로그인 화면이면 무시(멱등)
                sessionClient.resetSession()
                state = .login(LoginFeature.State())
                return .none

            case .splash(.delegate(.didFinishSplash(let hasValidToken, let hasNickname, let hasCompletedOnboarding))):
                state = Self.resolveRoot(
                    hasValidToken: hasValidToken,
                    hasNickname: hasNickname,
                    hasCompletedOnboarding: hasCompletedOnboarding
                )
                routePendingIfMain(&state)
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
                routePendingIfMain(&state)
                return .none

            case .login:
                return .none

            case .nicknameSetup(.delegate(.didSetNickname)):
                state = .onboarding(OnboardingStartFeature.State())
                return .none

            case .nicknameSetup:
                return .none

            case .onboarding(.delegate(.didCompleteOnboarding)):
                state = .main(MainFeature.State())
                routePendingIfMain(&state)
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
            OnboardingStartFeature()
        }
        .ifCaseLet(\.main, action: \.main) {
            MainFeature()
        }
    }
}

// MARK: - Deeplink 라우팅

extension AppFeature {

    /// main 상태로 진입한 직후, 아직 처리되지 못한 딥링크(콜드런치 등)가 있으면 적용한다.
    private func routePendingIfMain(_ state: inout State) {
        guard case .main(var main) = state, let pending = deeplinkClient.takePending() else { return }
        apply(pending, to: &main)
        state = .main(main)
    }

    private func apply(_ deeplink: Deeplink, to main: inout MainFeature.State) {
        switch deeplink {
        case .policyDetail(let id):
            main.selectedTab = .home
            // 같은 정책 상세가 이미 홈 스택 최상단이면 중복 push하지 않는다.
            if case .policyDetail(let top) = main.home.path.last, top.policyId == id { return }
            main.home.path.append(.policyDetail(PolicyDetailFeature.State(policyId: id)))
            analytics.track(.policyDetailView(policyId: id, policyName: nil, category: nil, entryPoint: .deeplink))
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
        guard hasCompletedOnboarding else { return .onboarding(OnboardingStartFeature.State()) }
        return .main(MainFeature.State())
    }
}
