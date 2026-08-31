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
            $0.sessionClient.userName = { nil }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
            $0.feed = .loading
        }
        await store.receive(\.feedResponse.success) {
            $0.feed = .loaded(.mock)
        }
    }

    @Test("조회에 실패하면 feed가 failed가 된다")
    func task_failure_setsFailed() async {
        let store = TestStore(initialState: HomeFeature.State()) {
            HomeFeature()
        } withDependencies: {
            $0.homeClient.fetchHomeFeed = { _ in throw UseCaseError.network }
            $0.sessionClient.userName = { nil }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
            $0.feed = .loading
        }
        await store.receive(\.feedResponse.failure) {
            $0.feed = .failed("네트워크 연결을 확인해 주세요.")
        }
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

    @Test("이미 로드된 상태에서 재진입하면 재요청하지 않는다")
    func task_whenAlreadyLoaded_isNoop() async {
        var state = HomeFeature.State()
        state.feed = .loaded(.mock)
        let store = TestStore(initialState: state) {
            HomeFeature()
        } withDependencies: {
            $0.sessionClient.userName = { nil }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
        }
    }
}
