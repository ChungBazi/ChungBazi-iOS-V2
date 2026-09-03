// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct NotificationFeatureTests {

    @Test("진입 시 첫 페이지 조회에 성공하면 loaded가 된다")
    func onAppear_success_loadsFirstPage() async {
        let store = TestStore(initialState: NotificationFeature.State()) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetch = { _, _, _ in .mock }
        }

        await store.send(.onAppear) {
            $0.notifications = .loading
        }
        await store.receive(\.pageResponse) {
            $0.notifications = .loaded(IdentifiedArray(uniqueElements: NotificationItemVO.mockList))
        }
    }

    @Test("첫 페이지 조회에 실패하면 failed가 된다")
    func onAppear_failure_setsFailed() async {
        let store = TestStore(initialState: NotificationFeature.State()) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetch = { _, _, _ in throw UseCaseError.offline }
        }

        await store.send(.onAppear) {
            $0.notifications = .loading
        }
        await store.receive(\.pageResponse) {
            $0.notifications = .failed(UseCaseError.offline.loadFailureMessage)
        }
    }

    @Test("목록 끝에 도달하면 다음 페이지를 이어붙인다")
    func didReachListEnd_appendsNextPage() async {
        var state = NotificationFeature.State()
        state.notifications = .loaded([NotificationItemVO.mockList[0]])
        state.pagination.nextCursor = 10
        state.pagination.hasNext = true

        let store = TestStore(initialState: state) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.fetch = { _, _, _ in
                NotificationPageVO(items: [NotificationItemVO.mockList[1]], nextCursor: nil, hasNext: false)
            }
        }

        await store.send(.didReachListEnd) {
            $0.pagination.isLoadingNext = true
        }
        await store.receive(\.pageResponse) {
            $0.notifications = .loaded([NotificationItemVO.mockList[0], NotificationItemVO.mockList[1]])
            $0.pagination = PaginationState<Int>()
        }
    }

    @Test("스와이프 삭제는 해당 알림을 즉시 제거한다")
    func didSwipeDelete_removesOptimistically() async {
        var state = NotificationFeature.State()
        state.notifications = .loaded(IdentifiedArray(uniqueElements: NotificationItemVO.mockList))
        let store = TestStore(initialState: state) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.delete = { _ in }
        }

        var expected = IdentifiedArray(uniqueElements: NotificationItemVO.mockList)
        expected.remove(id: 1)

        await store.send(.didSwipeDelete(id: 1)) {
            $0.notifications = .loaded(expected)
        }
    }

    @Test("전체 삭제를 확정하면 목록을 비운다")
    func didConfirmDeleteAll_clearsList() async {
        var state = NotificationFeature.State()
        state.notifications = .loaded(IdentifiedArray(uniqueElements: NotificationItemVO.mockList))
        state.pagination.hasNext = true
        state.pagination.nextCursor = 10
        let store = TestStore(initialState: state) {
            NotificationFeature()
        } withDependencies: {
            $0.notificationClient.deleteAll = {}
        }

        await store.send(.didConfirmDeleteAll) {
            $0.notifications = .loaded([])
            $0.pagination = PaginationState<Int>()
        }
    }

    @Test("알림 탭 시 정책 상세 이동을 부모에 위임한다 (읽음 처리는 서버가 담당)")
    func didTapNotification_delegatesSelectPolicy() async {
        var state = NotificationFeature.State()
        state.notifications = .loaded(IdentifiedArray(uniqueElements: NotificationItemVO.mockList))
        let store = TestStore(initialState: state) {
            NotificationFeature()
        }

        await store.send(.didTapNotification(id: 1))
        await store.receive(\.delegate)
    }
}
