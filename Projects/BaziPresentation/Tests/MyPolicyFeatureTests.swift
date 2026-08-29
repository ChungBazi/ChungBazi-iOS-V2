// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct MyPolicyFeatureTests {

    private static func page(_ items: [PolicySummaryVO]) -> PolicyPageVO {
        PolicyPageVO(
            policies: IdentifiedArray(uniqueElements: items),
            nextCursor: nil,
            hasNext: false,
            totalCount: items.count
        )
    }

    @Test("상시모집 탭으로 바꾸면 상시모집 목록을 조회한다")
    func didSelectTab_loadsOpenEnded() async {
        let items = Array(PolicySummaryVO.mockList.prefix(3))
        let store = TestStore(initialState: MyPolicyFeature.State()) {
            MyPolicyFeature()
        } withDependencies: {
            $0.myPolicyClient.fetchOpenEnded = { _, _ in Self.page(items) }
        }

        await store.send(.didSelectTab(.openEnded)) {
            $0.selectedTab = .openEnded
            $0.openEndedPolicies = .loading
        }
        await store.receive(\.pageResponse.success) {
            $0.openEndedPolicies = .loaded(IdentifiedArray(uniqueElements: items))
            $0.openEndedPagination.totalCount = items.count
        }
    }

    @Test("이미 로드된 상시모집은 탭 재전환 시 다시 부르지 않는다(State 캐시)")
    func didSelectTab_openEnded_usesCache() async {
        let cachedOpen = Array(PolicySummaryVO.mockList.prefix(3))
        let dateItems = Array(PolicySummaryVO.mockList.prefix(2))

        var state = MyPolicyFeature.State()
        state.selectedTab = .openEnded
        state.openEndedPolicies = .loaded(IdentifiedArray(uniqueElements: cachedOpen))
        state.openEndedPagination.totalCount = cachedOpen.count

        let store = TestStore(initialState: state) {
            MyPolicyFeature()
        } withDependencies: {
            $0.myPolicyClient.fetchDeadlineDate = { _, _, _, _ in Self.page(dateItems) }
        }

        // 정책 탭 최초 진입 → 정책 조회
        await store.send(.didSelectTab(.policy)) {
            $0.selectedTab = .policy
            $0.datePolicies = .loading
        }
        await store.receive(\.pageResponse.success) {
            $0.datePolicies = .loaded(IdentifiedArray(uniqueElements: dateItems))
            $0.datePagination.totalCount = dateItems.count
            $0.loadedDate = $0.selectedDate
        }

        // 다시 상시모집 → State 캐시 사용(추가 네트워크 호출 없음: 미수신 effect가 있으면 TestStore가 실패시킨다).
        await store.send(.didSelectTab(.openEnded)) {
            $0.selectedTab = .openEnded
        }
    }

    @Test("정렬 변경 시 정책 탭 목록을 다시 조회한다")
    func didTapSortOrder_reloads() async {
        let items = Array(PolicySummaryVO.mockList.prefix(2))

        var state = MyPolicyFeature.State()
        state.datePolicies = .loaded(IdentifiedArray(uniqueElements: Array(PolicySummaryVO.mockList.prefix(3))))
        state.datePagination.totalCount = 3

        let store = TestStore(initialState: state) {
            MyPolicyFeature()
        } withDependencies: {
            $0.myPolicyClient.fetchDeadlineDate = { _, _, _, _ in Self.page(items) }
        }

        await store.send(.didTapSortOrder) {
            $0.sortOrder = .latest
            $0.datePolicies = .loading
            $0.datePagination.reset()
        }
        await store.receive(\.pageResponse.success) {
            $0.datePolicies = .loaded(IdentifiedArray(uniqueElements: items))
            $0.datePagination.totalCount = items.count
            $0.loadedDate = $0.selectedDate
        }
    }
}
