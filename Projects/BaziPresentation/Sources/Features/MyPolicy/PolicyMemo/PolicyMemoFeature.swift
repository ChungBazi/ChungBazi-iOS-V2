// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 정책 메모 화면 (22). 캘린더/내 정책 카드에서 진입해 신청 일정을 메모한다.
@Reducer
public struct PolicyMemoFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let policyId: Int
        public var memo: PolicyMemo?
        public var draftText: String

        public var isSaveEnabled: Bool {
            draftText != (memo?.memo ?? "")
        }

        public init(policyId: Int) {
            self.policyId = policyId
            self.memo = nil
            self.draftText = ""
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didChangeDraftText(String)
        case didTapSave

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSaveMemo(policyId: Int, memo: String)
    }

    // MARK: - Dependencies

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 추가
    // @Dependency(\.myPolicyClient) var myPolicyClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // TODO: myPolicyClient가 준비되면 MyPolicyAPI.getMemo 응답으로 교체한다.
                let memo = PolicyMemo.mock(policyId: state.policyId)
                state.memo = memo
                state.draftText = memo.memo
                return .none

            case .didChangeDraftText(let text):
                state.draftText = text
                return .none

            case .didTapSave:
                guard state.isSaveEnabled else { return .none }
                let draftText = state.draftText
                state.memo?.memo = draftText
                return .send(.delegate(.didSaveMemo(policyId: state.policyId, memo: draftText)))

            case .delegate:
                return .none
            }
        }
    }
}
