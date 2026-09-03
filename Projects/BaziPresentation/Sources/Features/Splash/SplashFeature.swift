// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@Reducer
public struct SplashFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        var phase: Phase = .tagline
        var isMinimumDurationElapsed = false
        var sessionResult: SessionResult?
        /// RemoteConfig 게이트 평가 결과. nil이면 아직 평가 전. .normal이어야 다음 화면으로 진입한다.
        var gate: AppLaunchGate?

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
        case didTapForceUpdate
        case didTapMaintenanceConfirm

        // MARK: Internal
        case didAdvancePhase
        case didFinishMinimumDuration
        case sessionChecked(hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool)
        case gateResolved(AppLaunchGate)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    @CasePathable
    public enum Delegate: Equatable {
        case didFinishSplash(hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool)
    }

    // MARK: - Dependencies

    @Dependency(\.continuousClock) var clock
    @Dependency(\.splashClient) var splashClient
    @Dependency(\.appConfigClient) var appConfigClient
    @Dependency(\.openURL) var openURL
    @Dependency(\.exitApp) var exitApp

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
                        let session = await splashClient.checkSession()
                        await send(.sessionChecked(
                            hasValidToken: session.hasValidToken,
                            hasNickname: session.hasNickname,
                            hasCompletedOnboarding: session.hasCompletedOnboarding
                        ))
                    },
                    .run { [appConfigClient] send in
                        await send(.gateResolved(appConfigClient.evaluateGate()))
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

            case .gateResolved(let gate):
                state.gate = gate
                return finishIfReady(state: state)

            case .didTapForceUpdate:
                guard let url = ProfileConstants.appStoreURL else { return .none }
                return .run { [openURL] _ in _ = await openURL(url) }

            case .didTapMaintenanceConfirm:
                return .run { [exitApp] _ in exitApp() }

            case .delegate:
                return .none
            }
        }
    }

    // MARK: - Private

    /// 최소 노출 시간(태그라인 1초 + 로고 1초)·세션 체크·게이트 평가가 모두 끝나고
    /// 게이트가 정상일 때만 다음 화면으로 넘어간다. (점검/강제업데이트면 스플래시에 머문다)
    private func finishIfReady(state: State) -> Effect<Action> {
        guard
            state.isMinimumDurationElapsed,
            let result = state.sessionResult,
            state.gate == .normal
        else { return .none }
        return .send(.delegate(.didFinishSplash(
            hasValidToken: result.hasValidToken,
            hasNickname: result.hasNickname,
            hasCompletedOnboarding: result.hasCompletedOnboarding
        )))
    }
}
