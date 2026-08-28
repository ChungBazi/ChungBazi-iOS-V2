// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

/// 프로필 > 내 정보 수정 > 탈퇴하기(32).
/// 안내 확인 → 탈퇴 사유 선택 → "정말 탈퇴하시겠어요?" 확인 알럿 → 완료 알럿 순서로 진행된다.
@Reducer
public struct WithdrawFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var hasConfirmedNotice = false
        public var selectedReasons: Set<String> = []
        public var detailText = ""
        public var isWithdrawing = false
        public var activeAlert: ActiveAlert?

        public var isSubmitEnabled: Bool {
            hasConfirmedNotice && !selectedReasons.isEmpty && !isWithdrawing
        }

        public init() {}
    }

    // MARK: - Alert

    public enum ActiveAlert: Equatable {
        case confirm
        case completion
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case didToggleConfirmedNotice
        case didToggleReason(String)
        case didChangeDetailText(String)
        case didTapWithdrawButton
        case didCancelConfirm
        case didConfirmWithdraw
        case didTapCompletionConfirm

        // MARK: Internal
        case didFinishWithdraw

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didCompleteWithdrawal
    }

    // MARK: - Dependencies

    @Dependency(\.sessionClient) var sessionClient
    // TODO: BaziDomain의 회원 탈퇴 UseCase가 준비되면 추가
    // @Dependency(\.withdrawClient) var withdrawClient

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didToggleConfirmedNotice:
                state.hasConfirmedNotice.toggle()
                return .none

            case .didToggleReason(let reason):
                if state.selectedReasons.contains(reason) {
                    state.selectedReasons.remove(reason)
                } else {
                    state.selectedReasons.insert(reason)
                }
                return .none

            case .didChangeDetailText(let text):
                state.detailText = text
                return .none

            case .didTapWithdrawButton:
                guard state.isSubmitEnabled else { return .none }
                state.activeAlert = .confirm
                return .none

            case .didCancelConfirm:
                state.activeAlert = nil
                return .none

            case .didConfirmWithdraw:
                state.activeAlert = nil
                state.isWithdrawing = true
                // TODO: withdrawClient가 준비되면 UserAPI.withdraw(reasons:detail:) 호출로 교체한다.
                return .run { send in
                    await send(.didFinishWithdraw)
                }

            case .didFinishWithdraw:
                state.isWithdrawing = false
                state.activeAlert = .completion
                return .none

            case .didTapCompletionConfirm:
                state.activeAlert = nil
                return .run { [sessionClient] send in
                    sessionClient.resetSession()
                    await send(.delegate(.didCompleteWithdrawal))
                }

            case .delegate:
                return .none
            }
        }
    }
}

// MARK: - Reasons

extension WithdrawFeature {

    public static let reasons = [
        "원하는 정책을 찾기 어려워요.",
        "저에게 맞는 정책 추천이 부족해요.",
        "이용할 일이 없어졌어요.",
        "앱 사용이 불편했어요.",
        "오류가 자주 발생했어요.",
        "기타 이유가 있어요.",
    ]
}
