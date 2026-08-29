// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct MyPolicyListFeatureTests {

    @Test("task 진입 시 목록을 조회해 loaded가 된다")
    func task_loadsPolicies() async {
        let items = Array(PolicySummaryVO.mockList.prefix(3))
        let store = TestStore(initialState: MyPolicyListFeature.State()) {
            MyPolicyListFeature()
        } withDependencies: {
            $0.myPolicyListClient.fetchMyPolicies = { _, _, _, _ in
                PolicyPageVO(
                    policies: IdentifiedArray(uniqueElements: items),
                    nextCursor: nil,
                    hasNext: false,
                    totalCount: items.count
                )
            }
        }

        await store.send(.task) {
            $0.list = .loading
        }
        await store.receive(\.pageResponse.success) {
            $0.list = .loaded(IdentifiedArray(uniqueElements: items))
            $0.pagination.totalCount = items.count
        }
    }

    @Test("정렬 변경 시 1페이지를 다시 조회한다")
    func didTapSortOrder_reloadsFirstPage() async {
        let initialItems = Array(PolicySummaryVO.mockList.prefix(3))
        let sortedItems = Array(PolicySummaryVO.mockList.prefix(2))

        var state = MyPolicyListFeature.State()
        state.list = .loaded(IdentifiedArray(uniqueElements: initialItems))
        state.pagination.totalCount = initialItems.count

        let store = TestStore(initialState: state) {
            MyPolicyListFeature()
        } withDependencies: {
            $0.myPolicyListClient.fetchMyPolicies = { _, _, _, _ in
                PolicyPageVO(
                    policies: IdentifiedArray(uniqueElements: sortedItems),
                    nextCursor: nil,
                    hasNext: false,
                    totalCount: sortedItems.count
                )
            }
        }

        await store.send(.didTapSortOrder) {
            $0.sortOrder = .latest
            $0.list = .loading
            $0.pagination.reset()
        }
        await store.receive(\.pageResponse.success) {
            $0.list = .loaded(IdentifiedArray(uniqueElements: sortedItems))
            $0.pagination.totalCount = sortedItems.count
        }
    }

    @Test("찜 토글은 낙관적으로 반영된다")
    func didToggleLike_optimistic() async {
        var first = PolicySummaryVO.mockList[0]
        first.isLiked = false
        let state0 = IdentifiedArray(uniqueElements: [first])

        var state = MyPolicyListFeature.State()
        state.list = .loaded(state0)

        let store = TestStore(initialState: state) {
            MyPolicyListFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in }
        }

        await store.send(.didToggleLike(id: first.id)) {
            $0.list.value?[id: first.id]?.isLiked = true
        }
    }
}
