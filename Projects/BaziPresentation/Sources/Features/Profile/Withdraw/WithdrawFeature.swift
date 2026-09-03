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
        // 요청 시점의 이유 스냅샷을 함께 전달해 완료 이벤트가 실제 요청 내용과 일치하도록 한다.
        case didFinishWithdraw(reasons: [String])
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
    @Dependency(\.analytics) var analytics

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
                // 탈퇴 처리 중에는 이유 변경을 막는다(서버 요청 이유와 완료 이벤트 이유의 불일치 방지).
                guard !state.isWithdrawing else { return .none }
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
                let selected = WithdrawReasonUI.allCases.filter { state.selectedReasons.contains($0) }
                let reasons = selected.map { $0.toDomain() }
                let trimmed = state.detailText.trimmingCharacters(in: .whitespacesAndNewlines)
                let request = WithdrawRequest(reasons: reasons, detail: trimmed.isEmpty ? nil : trimmed)
                // 요청 시점의 이유를 스냅샷해 완료 이벤트로 전달한다(요청 중 이유 변경과의 불일치 방지).
                let eventReasons = selected.map(\.rawValue)
                return .run { [withdrawClient] send in
                    // 서버 탈퇴가 성공해야 완료 처리한다.
                    do {
                        try await withdrawClient.withdraw(request)
                        await send(.didFinishWithdraw(reasons: eventReasons))
                    } catch {
                        await send(.didFailWithdraw)
                    }
                }

            case let .didFinishWithdraw(reasons):
                state.isWithdrawing = false
                state.activeAlert = .completion
                return .run { [analytics] _ in analytics.track(.withdrawComplete(reasons: reasons)) }

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
