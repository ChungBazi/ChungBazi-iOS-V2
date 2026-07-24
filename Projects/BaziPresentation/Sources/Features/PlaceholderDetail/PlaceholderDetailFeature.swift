// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import ComposableArchitecture

/// Home 탭의 push 네비게이션 패턴을 검증하기 위한 임시 Feature.
/// BaziDomain에 실제 정책 상세 UseCase가 준비되면 PolicyDetailFeature로 교체한다.
@Reducer
public struct PlaceholderDetailFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable, Identifiable {
        public let id: UUID

        public init(id: UUID) {
            self.id = id
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        case onAppear
    }

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            }
        }
    }
}
