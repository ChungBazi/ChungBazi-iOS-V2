// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct RankedPolicyListFeatureTests {

    @Test("다음 페이지 응답은 기존 목록에 이어붙이고 페이지네이션을 갱신한다")
    func pageResponse_nextPage_appends() async {
        var state = RankedPolicyListFeature.State(kind: .popular)
        state.list = .loaded(IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(2))))
        state.pagination.isLoadingNext = true

        let store = TestStore(initialState: state) {
            RankedPolicyListFeature()
        }

        let nextPage = PolicyPageVO(
            policies: IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList[2...3])),
            nextCursor: "cursor2",
            hasNext: true,
            totalCount: 10
        )

        await store.send(.pageResponse(.success(nextPage), isFirstPage: false)) {
            $0.list = .loaded(IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(4))))
            $0.pagination.nextCursor = "cursor2"
            $0.pagination.hasNext = true
            $0.pagination.totalCount = 10
            $0.pagination.isLoadingNext = false
        }
    }

    @Test("찜 실패 시 낙관적 갱신을 롤백한다")
    func didToggleLike_rollsBackOnFailure() async {
        var state = RankedPolicyListFeature.State(kind: .popular)
        state.list = .loaded(IdentifiedArray(uniqueElements: [PolicySummaryVO.mockList[0]]))

        let store = TestStore(initialState: state) {
            RankedPolicyListFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in throw UseCaseError.network }
        }

        await store.send(.didToggleLike(id: 1)) {
            var summary = PolicySummaryVO.mockList[0]
            summary.isLiked = true
            $0.list = .loaded([summary])
        }
        await store.receive(\.likeFailed) {
            $0.list = .loaded([PolicySummaryVO.mockList[0]])
        }
    }
}
