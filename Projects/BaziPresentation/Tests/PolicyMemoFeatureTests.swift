// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct PolicyMemoFeatureTests {

    private nonisolated static let memo = PolicyMemoVO(
        policyId: 1,
        category: .job,
        dDay: "D-5",
        title: "청년 디지털 직무역량 지원",
        memo: "기존 메모"
    )

    @Test("진입 시 메모를 조회해 loaded가 되고 draftText를 채운다")
    func onAppear_loadsMemo() async {
        let store = TestStore(initialState: PolicyMemoFeature.State(policyId: 1)) {
            PolicyMemoFeature()
        } withDependencies: {
            $0.policyMemoClient.fetchMemo = { _ in Self.memo }
        }

        await store.send(.onAppear) {
            $0.memo = .loading
        }
        await store.receive(\.memoResponse.success) {
            $0.memo = .loaded(Self.memo)
            $0.draftText = "기존 메모"
        }
    }

    @Test("저장 시 서버에 반영하고 상위에 알린다(화면 유지)")
    func didTapSave_savesAndNotifies() async {
        var state = PolicyMemoFeature.State(policyId: 1)
        state.memo = .loaded(Self.memo)
        state.draftText = "수정한 메모"

        let store = TestStore(initialState: state) {
            PolicyMemoFeature()
        } withDependencies: {
            $0.policyMemoClient.updateMemo = { _, _ in }
        }

        await store.send(.didTapSave) {
            $0.isSaving = true
        }
        await store.receive(\.saveSucceeded) {
            $0.isSaving = false
            var updated = Self.memo
            updated.memo = "수정한 메모"
            $0.memo = .loaded(updated)
        }
        await store.receive(\.delegate.didSaveMemo)
    }

    @Test("변경이 없으면 저장 버튼이 비활성이라 저장하지 않는다")
    func didTapSave_noChange_doesNothing() async {
        var state = PolicyMemoFeature.State(policyId: 1)
        state.memo = .loaded(Self.memo)
        state.draftText = Self.memo.memo

        let store = TestStore(initialState: state) {
            PolicyMemoFeature()
        }

        await store.send(.didTapSave)
    }
}
