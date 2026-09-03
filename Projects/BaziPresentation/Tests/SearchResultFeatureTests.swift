// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct SearchResultFeatureTests {

    @Test("진입 시 검색 결과를 조회해 loaded가 된다")
    func onAppear_loadsResults() async {
        let store = TestStore(initialState: SearchResultFeature.State(query: "청년")) {
            SearchResultFeature()
        } withDependencies: {
            $0.policySearchClient.search = { _, _, _, _, _ in
                PolicyPageVO(
                    policies: IdentifiedArray(uniqueElements: PolicySummaryVO.mockList),
                    nextCursor: nil,
                    hasNext: false,
                    totalCount: PolicySummaryVO.mockList.count
                )
            }
        }

        await store.send(.onAppear) {
            $0.results = .loading
        }
        await store.receive(\.pageResponse) {
            $0.results = .loaded(IdentifiedArray(uniqueElements: PolicySummaryVO.mockList))
            $0.pagination.totalCount = PolicySummaryVO.mockList.count
        }
    }

    @Test("찜 토글 실패 시 낙관적 갱신을 롤백한다")
    func didToggleLike_rollsBackOnFailure() async {
        var state = SearchResultFeature.State(query: "청년")
        let item = PolicySummaryVO.mockList[0]
        state.results = .loaded([item])
        let store = TestStore(initialState: state) {
            SearchResultFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in throw UseCaseError.offline }
        }

        var liked = item
        liked.isLiked = true

        await store.send(.didToggleLike(id: item.id)) {
            $0.results = .loaded([liked])
            $0.$likeOverrides.withLock { $0[item.id] = true }
        }
        await store.receive(\.likeFailed) {
            $0.results = .loaded([item])
            $0.$likeOverrides.withLock { $0[item.id] = false }
        }
    }

    @Test("정책 탭은 상세 이동을 부모에 위임한다")
    func didTapPolicy_delegatesSelectPolicy() async {
        var state = SearchResultFeature.State(query: "청년")
        state.results = .loaded(IdentifiedArray(uniqueElements: PolicySummaryVO.mockList))
        let store = TestStore(initialState: state) {
            SearchResultFeature()
        }

        await store.send(.didTapPolicy(id: 1))
        await store.receive(\.delegate)
    }
}
