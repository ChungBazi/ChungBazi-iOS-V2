// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

@Reducer
public struct HomeFeature {

    // MARK: - Navigation

    @Reducer
    public enum Path {
        case detail(PlaceholderDetailFeature)
    }

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var path = StackState<Path.State>()

        public init() {}
    }

    // MARK: - Action

    public enum Action {
        // MARK: View
        case onAppear
        case didTapPlaceholderRow

        // MARK: Child
        case path(StackActionOf<Path>)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 정책 UseCase가 준비되면 추가
    // @Dependency(\.policyClient) var policyClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: policyClient가 준비되면 홈 섹션 데이터를 불러온다.
                return .none

            case .didTapPlaceholderRow:
                state.path.append(.detail(PlaceholderDetailFeature.State(id: UUID())))
                return .none

            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension HomeFeature.Path.State: Equatable {}
