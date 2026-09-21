// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct HomeFeatureTests {

    @Test("홈 진입 시 조회에 성공하면 feed가 loaded가 된다")
    func task_success_loadsFeed() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchHomeFeed = { _ in .mock }
            // .onAppear가 loadFeed와 fetchUnreadStatus를 .merge로 동시 실행하므로,
            // 완료 순서를 가정하지 않기 위해 이 테스트와 무관한 쪽은 끝나지 않게 둔다.
            $0.homeClient.fetchUnreadStatus = { try await Task.never() }
            $0.sessionClient.userName = { nil }
            $0.sessionClient.displayName = { "회원" }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
            $0.feed = .loading
        }
        await store.receive(\.feedResponse.success) {
            $0.feed = .loaded(.mock)
        }
        // fetchUnreadStatus는 이 테스트에서 검증 대상이 아니라 일부러 끝나지 않게 뒀으므로, 남은 이펙트는 무시한다.
        await store.skipInFlightEffects()
    }

    @Test("조회에 실패하면 feed가 failed가 된다")
    func task_failure_setsFailed() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchHomeFeed = { _ in throw UseCaseError.offline }
            // 완료 순서를 가정하지 않기 위해 이 테스트와 무관한 쪽은 끝나지 않게 둔다.
            $0.homeClient.fetchUnreadStatus = { try await Task.never() }
            $0.sessionClient.userName = { nil }
            $0.sessionClient.displayName = { "회원" }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
            $0.feed = .loading
        }
        await store.receive(\.feedResponse.failure) {
            $0.feed = .failed(UseCaseError.offline.loadFailureMessage)
        }
        // fetchUnreadStatus는 이 테스트에서 검증 대상이 아니라 일부러 끝나지 않게 뒀으므로, 남은 이펙트는 무시한다.
        await store.skipInFlightEffects()
    }

    @Test("홈 진입 시 배지 상태 조회에 성공하면 반영된다")
    func task_success_updatesUnreadStatus() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchHomeFeed = { _ in try await Task.never() }
            $0.homeClient.fetchUnreadStatus = { true }
            $0.sessionClient.userName = { nil }
            $0.sessionClient.displayName = { "회원" }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
            $0.feed = .loading
        }
        await store.receive(\.unreadStatusResponse.success) {
            $0.hasUnreadNotification = true
        }
        // fetchHomeFeed는 이 테스트에서 검증 대상이 아니라 일부러 끝나지 않게 뒀으므로, 남은 이펙트는 무시한다.
        await store.skipInFlightEffects()
    }

    @Test("안읽음 배지 상태 조회가 실패해도 기존 배지 상태를 그대로 유지한다")
    func unreadStatusResponse_failure_isIgnored() async {
        var state = HomeFeature.State()
        state.hasUnreadNotification = true
        let store = TestStore(initialState: state) {
            HomeFeature()
        }

        await store.send(.unreadStatusResponse(.failure(.offline)))
    }

    @Test("찜 토글은 모든 섹션의 해당 정책 찜 상태를 뒤집는다")
    func didToggleLike_togglesInLoadedFeed() async {
        var state = HomeFeature.State()
        state.feed = .loaded(.mock)
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in }
        }

        var expected = HomeFeedVO.mock
        expected.setLiked(id: 1, liked: true) // id 1은 맞춤·인기 양쪽에 있어 두 섹션 모두 반영된다

        await store.send(.didToggleLike(section: .popular, id: 1)) {
            $0.feed = .loaded(expected)
            $0.$likeOverrides.withLock { $0[1] = true }
        }
    }

    @Test("이미 로드된 상태에서 재진입하면 feed는 재요청하지 않지만 배지 상태는 다시 조회한다")
    func task_whenAlreadyLoaded_skipsFeedButRefreshesUnreadStatus() async {
        var state = HomeFeature.State()
        state.feed = .loaded(.mock)
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            // 기본값(false)과 다른 값을 반환해야 배지가 실제로 갱신됐는지 검증할 수 있다.
            $0.homeClient.fetchUnreadStatus = { true }
            $0.sessionClient.userName = { nil }
            $0.sessionClient.displayName = { "회원" }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
        }
        await store.receive(\.unreadStatusResponse.success) {
            $0.hasUnreadNotification = true
        }
    }

    @Test("당김 새로고침은 feed를 갱신한다")
    func pullToRefresh_refreshesFeed() async {
        var state = HomeFeature.State()
        state.feed = .loaded(.mock)
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchHomeFeed = { _ in .mock }
            // 배지 쪽은 이 테스트의 검증 대상이 아니므로 일부러 끝나지 않게 둔다.
            $0.homeClient.fetchUnreadStatus = { try await Task.never() }
            $0.sessionClient.userName = { nil }
        }

        await store.send(.pullToRefresh)
        await store.receive(\.feedResponse.success)
        await store.skipInFlightEffects()
    }

    @Test("당김 새로고침은 배지 상태도 함께 갱신한다")
    func pullToRefresh_refreshesUnreadStatus() async {
        var state = HomeFeature.State()
        state.feed = .loaded(.mock)
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            // feed 쪽은 이 테스트의 검증 대상이 아니므로 일부러 끝나지 않게 둔다.
            $0.homeClient.fetchHomeFeed = { _ in try await Task.never() }
            $0.homeClient.fetchUnreadStatus = { true }
            $0.sessionClient.userName = { nil }
        }

        await store.send(.pullToRefresh)
        await store.receive(\.unreadStatusResponse.success) {
            $0.hasUnreadNotification = true
        }
        await store.skipInFlightEffects()
    }

    @Test("피드 로드 실패 후 재시도는 feed를 다시 조회한다")
    func didTapRetry_refetchesFeed() async {
        var state = HomeFeature.State()
        state.feed = .failed("offline")
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchHomeFeed = { _ in .mock }
            // 배지 쪽은 이 테스트의 검증 대상이 아니므로 일부러 끝나지 않게 둔다.
            $0.homeClient.fetchUnreadStatus = { try await Task.never() }
            $0.sessionClient.userName = { nil }
        }

        await store.send(.didTapRetry) {
            $0.feed = .loading
        }
        await store.receive(\.feedResponse.success) {
            $0.feed = .loaded(.mock)
        }
        await store.skipInFlightEffects()
    }

    @Test("피드 로드 실패 후 재시도는 배지 상태도 함께 다시 조회한다")
    func didTapRetry_refetchesUnreadStatus() async {
        var state = HomeFeature.State()
        state.feed = .failed("offline")
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            // feed 쪽은 이 테스트의 검증 대상이 아니므로 일부러 끝나지 않게 둔다.
            $0.homeClient.fetchHomeFeed = { _ in try await Task.never() }
            $0.homeClient.fetchUnreadStatus = { true }
            $0.sessionClient.userName = { nil }
        }

        await store.send(.didTapRetry) {
            $0.feed = .loading
        }
        await store.receive(\.unreadStatusResponse.success) {
            $0.hasUnreadNotification = true
        }
        await store.skipInFlightEffects()
    }

    @Test("알림 목록 조회 후 복귀(didViewNotifications)하면 배지 상태를 다시 조회한다")
    func pathDelegate_didViewNotifications_refreshesUnreadStatus() async {
        var state = HomeFeature.State()
        state.hasUnreadNotification = true
        state.path.append(.notification(NotificationFeature.State()))
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchUnreadStatus = { false }
        }

        await store.send(.path(.element(id: 0, action: .notification(.delegate(.didViewNotifications)))))
        await store.receive(\.unreadStatusResponse.success) {
            $0.hasUnreadNotification = false
        }
    }
}
