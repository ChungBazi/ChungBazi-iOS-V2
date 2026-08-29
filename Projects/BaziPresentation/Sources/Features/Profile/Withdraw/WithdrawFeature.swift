// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

/// 프로필 > 내 정보 수정 > 탈퇴하기(32).
/// 안내 확인 → 탈퇴 사유 선택 → "정말 탈퇴하시겠어요?" 확인 알럿 → 완료 알럿 순서로 진행된다.
@Reducer
public struct WithdrawFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public var hasConfirmedNotice = false
        public var selectedReasons: Set<WithdrawReasonUI> = []
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
        case error
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case didToggleConfirmedNotice
        case didToggleReason(WithdrawReasonUI)
        case didChangeDetailText(String)
        case didTapWithdrawButton
        case didCancelConfirm
        case didConfirmWithdraw
        case didTapCompletionConfirm
        case didDismissError

        // MARK: Internal
        case didFinishWithdraw
        case didFailWithdraw

        // MARK: Delegate
        case delegate(Delegate)
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didCompleteWithdrawal
    }

    // MARK: - Dependencies

    @Dependency(\.sessionClient) var sessionClient
    @Dependency(\.withdrawClient) var withdrawClient

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
                // 선택 순서와 무관하게 표시 순서(allCases)로 정렬해 서버 코드로 매핑한다.
                let reasons = WithdrawReasonUI.allCases
                    .filter { state.selectedReasons.contains($0) }
                    .map { $0.toDomain() }
                let trimmed = state.detailText.trimmingCharacters(in: .whitespacesAndNewlines)
                let request = WithdrawRequest(reasons: reasons, detail: trimmed.isEmpty ? nil : trimmed)
                return .run { [withdrawClient] send in
                    // 서버 탈퇴가 성공해야 완료 처리한다.
                    do {
                        try await withdrawClient.withdraw(request)
                        await send(.didFinishWithdraw)
                    } catch {
                        await send(.didFailWithdraw)
                    }
                }

            case .didFinishWithdraw:
                state.isWithdrawing = false
                state.activeAlert = .completion
                return .none

            case .didFailWithdraw:
                state.isWithdrawing = false
                state.activeAlert = .error
                return .none

            case .didDismissError:
                state.activeAlert = nil
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
