// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@Reducer
public struct LoginFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case didTapKakaoLoginButton
        case didTapAppleLoginButton(idToken: String, name: String?)

        // MARK: Internal
        case loginResponse(Result<AccountStatus, UseCaseError>)

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

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didTapKakaoLoginButton:
                return .run { [authClient] send in
                    do {
                        let result = try await authClient.loginWithKakao()
                        await send(.loginResponse(.success(result)))
                    } catch {
                        await send(.loginResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .didTapAppleLoginButton(let idToken, let name):
                return .run { [authClient] send in
                    do {
                        let result = try await authClient.loginWithApple(idToken, name)
                        await send(.loginResponse(.success(result)))
                    } catch {
                        await send(.loginResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .loginResponse(.success(let result)):
                return .send(.delegate(.didLogin(
                    hasNickname: result.hasNickname,
                    hasCompletedOnboarding: result.hasCompletedOnboarding
                )))

            case .loginResponse(.failure):
                // TODO: 로그인 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
