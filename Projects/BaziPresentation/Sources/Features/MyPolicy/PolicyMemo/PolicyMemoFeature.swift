// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain
import ComposableArchitecture

/// 정책 메모 화면 (22). 캘린더/내 정책 카드에서 진입해 신청 일정을 메모한다.
/// 저장 버튼은 저장만(화면 유지), 뒤로가기는 변경분이 있으면 자동 저장 후 화면을 닫는다(메모앱 방식).
@Reducer
public struct PolicyMemoFeature {

    // MARK: - State

    @ObservableState
    public struct State: Equatable {
        public let policyId: Int
        public var memo: LoadingState<PolicyMemoVO> = .idle
        public var draftText: String = ""
        public var isSaving = false
        /// 저장 실패 안내 알림(자동저장 실패 시 재시도/폐기 후 나가기 경로 제공).
        @Presents public var alert: AlertState<Action.Alert>?

        /// 저장 버튼 활성: 로드 완료 + 저장 중 아님 + 저장된 값과 다름.
        public var isSaveEnabled: Bool {
            guard let saved = memo.value?.memo else { return false }
            return !isSaving && draftText != saved
        }

        public init(policyId: Int) {
            self.policyId = policyId
        }
    }

    // MARK: - Action

    public enum Action: Equatable {
        // MARK: View
        case onAppear
        case didChangeDraftText(String)
        case didTapSave
        case didTapBack

        // MARK: Internal
        case memoResponse(Result<PolicyMemoVO, UseCaseError>)
        case saveSucceeded(dismissAfter: Bool)
        case saveFailed(dismissAfter: Bool)
        case alert(PresentationAction<Alert>)

        // MARK: Delegate
        case delegate(Delegate)

        public enum Alert: Equatable {
            case retrySave
            case discardAndLeave
        }
    }

    // MARK: - Delegate

    public enum Delegate: Equatable {
        case didSaveMemo(policyId: Int, memo: String)
    }

    // MARK: - Dependencies

    @Dependency(\.policyMemoClient) var policyMemoClient
    @Dependency(\.dismiss) var dismiss

    // MARK: - Init

    public init() {}

    // MARK: - Body

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.memo.value == nil, !state.memo.isLoading else { return .none }
                state.memo = .loading
                return .run { [policyMemoClient, policyId = state.policyId] send in
                    do {
                        let memo = try await policyMemoClient.fetchMemo(policyId)
                        await send(.memoResponse(.success(memo)))
                    } catch {
                        await send(.memoResponse(.failure(UseCaseError.map(error))))
                    }
                }

            case .memoResponse(.success(let memo)):
                state.memo = .loaded(memo)
                state.draftText = memo.memo
                return .none

            case .memoResponse(.failure(let error)):
                state.memo = .failed(error.loadFailureMessage)
                return .none

            case .didChangeDraftText(let text):
                state.draftText = text
                return .none

            case .didTapSave:
                // 저장만 하고 화면은 유지한다(저장 이후에도 계속 편집 가능).
                guard state.isSaveEnabled else { return .none }
                return save(&state, dismissAfter: false)

            case .didTapBack:
                // 변경분이 있으면 저장 후 닫고, 없으면 바로 닫는다.
                guard state.isSaveEnabled else {
                    return .run { [dismiss] _ in await dismiss() }
                }
                return save(&state, dismissAfter: true)

            case let .saveSucceeded(dismissAfter):
                state.isSaving = false
                if var memo = state.memo.value {
                    memo.memo = state.draftText
                    state.memo = .loaded(memo)
                }
                let policyId = state.policyId
                let text = state.draftText
                return .run { [dismiss] send in
                    await send(.delegate(.didSaveMemo(policyId: policyId, memo: text)))
                    if dismissAfter { await dismiss() }
                }

            case let .saveFailed(dismissAfter):
                state.isSaving = false
                // 뒤로가기(자동저장) 실패면 재시도/폐기 후 나가기 선택지를 주고, 저장 버튼 실패면 안내만 한다.
                state.alert = dismissAfter ? .saveFailedOnExit : .saveFailed
                return .none

            case .alert(.presented(.retrySave)):
                return save(&state, dismissAfter: true)

            case .alert(.presented(.discardAndLeave)):
                return .run { [dismiss] _ in await dismiss() }

            case .alert:
                return .none

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }

    // MARK: - Private

    private func save(_ state: inout State, dismissAfter: Bool) -> Effect<Action> {
        state.isSaving = true
        let policyId = state.policyId
        let text = state.draftText
        return .run { [policyMemoClient] send in
            do {
                try await policyMemoClient.updateMemo(policyId, text)
                await send(.saveSucceeded(dismissAfter: dismissAfter))
            } catch {
                await send(.saveFailed(dismissAfter: dismissAfter))
            }
        }
    }
}

// MARK: - Alerts

extension AlertState where Action == PolicyMemoFeature.Action.Alert {

    /// 저장 버튼으로 저장하다 실패(화면 유지) — 안내만.
    static var saveFailed: Self {
        AlertState {
            TextState("저장에 실패했어요")
        } actions: {
            ButtonState(role: .cancel) { TextState("확인") }
        } message: {
            TextState("잠시 후 다시 시도해주세요.")
        }
    }

    /// 뒤로가기(자동저장) 중 실패 — 재시도 또는 저장 없이 나가기.
    static var saveFailedOnExit: Self {
        AlertState {
            TextState("저장에 실패했어요")
        } actions: {
            ButtonState(action: .retrySave) { TextState("다시 시도") }
            ButtonState(role: .destructive, action: .discardAndLeave) { TextState("저장하지 않고 나가기") }
            ButtonState(role: .cancel) { TextState("계속 편집") }
        } message: {
            TextState("변경사항을 저장하지 못했어요.")
        }
    }
}
