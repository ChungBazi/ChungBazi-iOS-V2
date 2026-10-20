// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 현재 로그인된 소셜 계정을 프로필 조회로 받아 표시한다. (해지 기능 없음)
@Reducer
public struct LinkedAccountsFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var profile: LoadingState<UserProfileVO> = .idle

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didTapRetry

        // MARK: Internal
        case profileResponse(Result<UserProfile, UseCaseError>)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {}

    // MARK: - Dependencies

    @Dependency(\.linkedAccountsClient) var linkedAccountsClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.profile.value == nil, !state.profile.isLoading else { return .none }
                return load(&state)

            case .didTapRetry:
                return load(&state)

            case .profileResponse(.success(let profile)):
                state.profile = .loaded(UserProfileVO(profile))
                return .none

            case .profileResponse(.failure(let error)):
                state.profile = .failed(error.loadFailureMessage)
                return .none

            case .delegate:
                return .none
            }
        }
    }

    private func load(_ state: inout State) -> Effect<Action> {
        state.profile = .loading
        return .run { [linkedAccountsClient] send in
            do {
                let profile = try await linkedAccountsClient.getProfile()
                await send(.profileResponse(.success(profile)))
            } catch {
                await send(.profileResponse(.failure(UseCaseError.map(error))))
            }
        }
    }
}
