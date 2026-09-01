// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct CustomPolicyListFeatureTests {

    @Test("진입 시 카드들을 병렬 조회해 loaded가 된다 (최소 로딩은 ImmediateClock으로 즉시)")
    func task_loadsCards() async {
        let store = TestStore(initialState: CustomPolicyListFeature.State()) {
            CustomPolicyListFeature()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.sessionClient.displayName = { "바지" }
            $0.customPolicyClient.hasSeenGuide = { true }
            $0.customPolicyClient.isAISummaryAvailable = { false }
            $0.customPolicyClient.fetchCards = { _ in PolicyCardVO.mockList }
        }

        await store.send(.onAppear) {
            $0.displayName = "바지"
            $0.cards = .loading
        }
        await store.receive(\.cardsResponse.success) {
            $0.cards = .loaded(IdentifiedArray(uniqueElements: PolicyCardVO.mockList))
        }
    }

    @Test("지원 기기에서 카드가 보이면 요약을 생성해 .ready가 된다")
    func didShowCard_summarizes() async {
        var state = CustomPolicyListFeature.State()
        state.cards = .loaded(IdentifiedArray(uniqueElements: [PolicyCardVO.mockList[0]]))

        let store = TestStore(initialState: state) {
            CustomPolicyListFeature()
        } withDependencies: {
            $0.continuousClock = ImmediateClock()
            $0.customPolicyClient.isAISummaryAvailable = { true }
            $0.customPolicyClient.summarize = { _ in "요약 결과" }
        }

        await store.send(.didShowCard(id: 1))
        await store.receive(\.summarizeStarted) {
            var card = PolicyCardVO.mockList[0]
            card.aiSummary = .loading
            $0.cards = .loaded([card])
        }
        await store.receive(\.summaryResponse) {
            var card = PolicyCardVO.mockList[0]
            card.aiSummary = .ready("요약 결과")
            $0.cards = .loaded([card])
        }
    }

    @Test("찜 실패 시 낙관적 갱신을 롤백한다")
    func didToggleLike_rollsBackOnFailure() async {
        var state = CustomPolicyListFeature.State()
        state.cards = .loaded(IdentifiedArray(uniqueElements: [PolicyCardVO.mockList[0]]))

        let store = TestStore(initialState: state) {
            CustomPolicyListFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in throw UseCaseError.network }
        }

        await store.send(.didToggleLike(id: 1)) {
            var card = PolicyCardVO.mockList[0]
            card.isLiked = true
            $0.cards = .loaded([card])
            $0.$likeOverrides.withLock { $0[1] = true }
        }
        await store.receive(\.likeFailed) {
            var card = PolicyCardVO.mockList[0]
            card.isLiked = false
            $0.cards = .loaded([card])
            $0.$likeOverrides.withLock { $0[1] = false }
        }
    }
}
