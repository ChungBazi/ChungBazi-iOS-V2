// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 현재 로그인된 소셜 계정을 프로필 조회로 받아 표시한다. (해지 기능 없음)
@Reducer
public struct LinkedAccountsFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var profile: UserProfileVO?

        public init() {}
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear

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
                return .run { [linkedAccountsClient] send in
                    do {
                        let profile = try await linkedAccountsClient.getProfile()
                        await send(.profileResponse(.success(profile)))
                    } catch {
                        await send(.profileResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .profileResponse(.success(let profile)):
                state.profile = UserProfileVO(profile)
                return .none

            case .profileResponse(.failure):
                // TODO: 소셜 계정 조회 실패 알림 UI가 정해지면 State에 반영.
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
