// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 프로필 > 내 정보 수정 > 로그인된 소셜 계정(35).
/// 연동된 계정이 1개뿐이면 계정 해지 시 로그인 수단이 사라지는 것을 막기 위해 해지를 비활성화한다.
@Reducer
public struct LinkedAccountsFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var accounts: IdentifiedArrayOf<SocialAccount>

        public var isUnlinkEnabled: Bool { accounts.count >= 2 }

        public init() {
            self.accounts = []
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didTapUnlink(id: SocialAccount.ID)

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {}

    // MARK: - Dependencies

    // TODO: BaziDomain의 연동 계정 조회/해지 UseCase가 준비되면 추가
    // @Dependency(\.linkedAccountsClient) var linkedAccountsClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: linkedAccountsClient가 준비되면 실제 서버 응답으로 교체한다.
                if state.accounts.isEmpty {
                    state.accounts = IdentifiedArray(uniqueElements: SocialAccount.mockList)
                }
                return .none

            case .didTapUnlink(let id):
                guard state.isUnlinkEnabled else { return .none }
                state.accounts.remove(id: id)
                return .none

            case .delegate:
                return .none
            }
        }
    }
}
