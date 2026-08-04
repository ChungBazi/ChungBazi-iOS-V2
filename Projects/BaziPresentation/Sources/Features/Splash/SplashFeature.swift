// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

@Reducer
public struct SplashFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        var phase: Phase = .tagline
        var isMinimumDurationElapsed = false
        var sessionResult: SessionResult?

        public init() {}
    }

    enum Phase: Equatable {
        case tagline
        case logo
    }

    struct SessionResult: Equatable {
        var hasValidToken: Bool
        var hasNickname: Bool
        var hasCompletedOnboarding: Bool
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear

        // MARK: Internal
        case didAdvancePhase
        case didFinishMinimumDuration
        case sessionChecked(hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didFinishSplash(hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool)
    }

    // MARK: - Dependencies

    @Dependency(\.continuousClock) var clock
    @Dependency(\.splashClient) var splashClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { [clock] send in
                        try await clock.sleep(for: .seconds(1))
                        await send(.didAdvancePhase)
                        try await clock.sleep(for: .seconds(1))
                        await send(.didFinishMinimumDuration)
                    },
                    .run { [splashClient] send in
                        let session = splashClient.checkSession()
                        await send(.sessionChecked(
                            hasValidToken: session.hasValidToken,
                            hasNickname: session.hasNickname,
                            hasCompletedOnboarding: session.hasCompletedOnboarding
                        ))
                    }
                )

            case .didAdvancePhase:
                state.phase = .logo
                return .none

            case .didFinishMinimumDuration:
                state.isMinimumDurationElapsed = true
                return finishIfReady(state: state)

            case .sessionChecked(let hasValidToken, let hasNickname, let hasCompletedOnboarding):
                state.sessionResult = SessionResult(
                    hasValidToken: hasValidToken,
                    hasNickname: hasNickname,
                    hasCompletedOnboarding: hasCompletedOnboarding
                )
                return finishIfReady(state: state)

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    /// 최소 노출 시간(태그라인 1초 + 로고 1초)과 세션 체크가 모두 끝나야 다음 화면으로 넘어간다.
    private func finishIfReady(state: State) -> Effect<Action> {
        guard state.isMinimumDurationElapsed, let result = state.sessionResult else { return .none }
        return .send(.delegate(.didFinishSplash(
            hasValidToken: result.hasValidToken,
            hasNickname: result.hasNickname,
            hasCompletedOnboarding: result.hasCompletedOnboarding
        )))
    }
}
