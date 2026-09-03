// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@Reducer
public struct LoginFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var isLoading = false
        var loginMethod: String?
        /// 로그인 실패 시 표시할 경고 토스트 메시지(nil이면 미표시). 사용자 취소는 미표시.
        public var errorToast: String?

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case didTapKakaoLoginButton
        case didTapAppleLoginButton

        // MARK: Internal
        case loginResponse(Result<AccountStatus, UseCaseError>)
        case dismissErrorToast

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        /// 로그인 성공 후 다음 root를 정하기 위해 필요한 사용자 상태.
        case didLogin(hasNickname: Bool, hasCompletedOnboarding: Bool)
    }

    // MARK: - Dependencies

    @Dependency(\.authClient) var authClient
    @Dependency(\.analytics) var analytics

    // MARK: - Init

    public init() {}

    // MARK: - CancelID

    private enum CancelID {
        case login
    }

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapKakaoLoginButton:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                state.loginMethod = "kakao"
                return .run { [authClient] send in
                    do {
                        let result = try await authClient.loginWithKakao()
                        await send(.loginResponse(.success(result)))
                    } catch {
                        await send(.loginResponse(.failure(UseCaseError.map(error))))
                    }
                }
                .cancellable(id: CancelID.login, cancelInFlight: true)

            case .didTapAppleLoginButton:
                guard !state.isLoading else { return .none }
                state.isLoading = true
                state.loginMethod = "apple"
                return .run { [authClient] send in
                    do {
                        let result = try await authClient.loginWithApple()
                        await send(.loginResponse(.success(result)))
                    } catch {
                        await send(.loginResponse(.failure(UseCaseError.map(error))))
                    }
                }
                .cancellable(id: CancelID.login, cancelInFlight: true)

            case .loginResponse(.success(let result)):
                state.isLoading = false
                // 추적을 먼저 끝낸 뒤 delegate 전송(부모의 state 교체로 인한 child effect 취소로 이벤트 유실 방지).
                return .concatenate(
                    .run { [analytics, method = state.loginMethod ?? "", isNewUser = !result.hasNickname] _ in
                        analytics.track(.login(method: method, isNewUser: isNewUser))
                    },
                    .send(.delegate(.didLogin(
                        hasNickname: result.hasNickname,
                        hasCompletedOnboarding: result.hasCompletedOnboarding
                    )))
                )

            case .loginResponse(.failure(let error)):
                state.isLoading = false
                // 사용자가 로그인 창을 닫은 취소는 오류로 띄우지 않는다.
                if error != .cancelled { state.errorToast = error.loadFailureMessage }
                return .none

            case .dismissErrorToast:
                state.errorToast = nil
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
