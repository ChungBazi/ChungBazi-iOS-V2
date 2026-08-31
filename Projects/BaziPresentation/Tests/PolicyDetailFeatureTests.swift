// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct PolicyDetailFeatureTests {

    @Test("진입 시 상세를 조회해 loaded가 된다")
    func onAppear_loadsDetail() async {
        let store = TestStore(initialState: PolicyDetailFeature.State(policyId: 1)) {
            PolicyDetailFeature()
        } withDependencies: {
            $0.policyDetailClient.fetch = { PolicyDetailVO.mock(id: $0) }
        }

        await store.send(.onAppear) {
            $0.displayName = "회원"
            $0.detail = .loading
        }
        await store.receive(\.detailResponse) {
            $0.detail = .loaded(PolicyDetailVO.mock(id: 1))
        }
    }

    @Test("상세 찜 실패 시 낙관적 갱신을 롤백한다")
    func didTapLike_rollsBackOnFailure() async {
        var state = PolicyDetailFeature.State(policyId: 1)
        state.detail = .loaded(PolicyDetailVO.mock(id: 1))
        let store = TestStore(initialState: state) {
            PolicyDetailFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in throw UseCaseError.network }
        }

        var liked = PolicyDetailVO.mock(id: 1)
        liked.isLiked = true

        await store.send(.didTapLike) {
            $0.detail = .loaded(liked)
            $0.$likeOverrides.withLock { $0[1] = true }
        }
        await store.receive(\.likeFailed) {
            $0.detail = .loaded(PolicyDetailVO.mock(id: 1))
            $0.$likeOverrides.withLock { $0[1] = false }
        }
    }

    @Test("추천 정책 찜 실패 시 낙관적 갱신을 롤백한다")
    func didToggleRecommendationLike_rollsBackOnFailure() async {
        var state = PolicyDetailFeature.State(policyId: 1)
        state.detail = .loaded(PolicyDetailVO.mock(id: 1))
        let store = TestStore(initialState: state) {
            PolicyDetailFeature()
        } withDependencies: {
            $0.policyLikeClient.setLike = { _, _ in throw UseCaseError.network }
        }

        var expected = PolicyDetailVO.mock(id: 1)
        expected.personalized[id: 1]?.isLiked = true

        await store.send(.didToggleRecommendationLike(section: .personalized, id: 1)) {
            $0.detail = .loaded(expected)
            $0.$likeOverrides.withLock { $0[1] = true }
        }
        await store.receive(\.recommendationLikeFailed) {
            $0.detail = .loaded(PolicyDetailVO.mock(id: 1))
            $0.$likeOverrides.withLock { $0[1] = false }
        }
    }

    @Test("추천 정책 탭은 상세 이동을 부모에 위임한다")
    func didTapPolicy_delegatesSelectPolicy() async {
        var state = PolicyDetailFeature.State(policyId: 1)
        state.detail = .loaded(PolicyDetailVO.mock(id: 1))
        let store = TestStore(initialState: state) {
            PolicyDetailFeature()
        }

        await store.send(.didTapPolicy(id: 2))
        await store.receive(\.delegate)
    }
}
