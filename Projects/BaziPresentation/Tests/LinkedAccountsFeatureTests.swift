// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct LinkedAccountsFeatureTests {

    // @Sendable인 getProfile 클로저에서 오프-액터로 접근하므로 nonisolated로 둔다. (UserProfile은 Sendable)
    private nonisolated static let profile = UserProfile(nickname: "바지", email: "chungbazi@kakao.com", socialType: .kakao)

    @Test("진입 시 프로필 조회에 성공하면 loaded가 된다")
    func onAppear_success_loaded() async {
        let store = TestStore(initialState: LinkedAccountsFeature.State()) {
            LinkedAccountsFeature()
        } withDependencies: {
            $0.linkedAccountsClient.getProfile = { Self.profile }
        }

        await store.send(.onAppear) {
            $0.profile = .loading
        }
        await store.receive(\.profileResponse) {
            $0.profile = .loaded(UserProfileVO(Self.profile))
        }
    }

    @Test("진입 시 조회에 실패하면 분류된 메시지로 failed가 된다")
    func onAppear_failure_failed() async {
        let store = TestStore(initialState: LinkedAccountsFeature.State()) {
            LinkedAccountsFeature()
        } withDependencies: {
            $0.linkedAccountsClient.getProfile = { throw UseCaseError.offline }
        }

        await store.send(.onAppear) {
            $0.profile = .loading
        }
        await store.receive(\.profileResponse) {
            $0.profile = .failed(UseCaseError.offline.loadFailureMessage)
        }
    }

    @Test("이미 loaded면 재진입해도 다시 요청하지 않는다")
    func onAppear_whenLoaded_skipsReload() async {
        var state = LinkedAccountsFeature.State()
        state.profile = .loaded(UserProfileVO(Self.profile))
        let store = TestStore(initialState: state) {
            LinkedAccountsFeature()
        }
        // getProfile을 override하지 않았으므로, 호출되면 unimplemented로 테스트가 실패한다.
        await store.send(.onAppear)
    }

    @Test("실패 상태에서 재시도하면 다시 로드해 loaded가 된다")
    func didTapRetry_reloads() async {
        var state = LinkedAccountsFeature.State()
        state.profile = .failed("일시 오류")
        let store = TestStore(initialState: state) {
            LinkedAccountsFeature()
        } withDependencies: {
            $0.linkedAccountsClient.getProfile = { Self.profile }
        }

        await store.send(.didTapRetry) {
            $0.profile = .loading
        }
        await store.receive(\.profileResponse) {
            $0.profile = .loaded(UserProfileVO(Self.profile))
        }
    }
}
