// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

@testable import BaziPresentation

@MainActor
struct ProfileFeatureTests {

    @Test("진입 시 닉네임과 업데이트 가용 여부를 세팅한다")
    func onAppearSetsNicknameAndUpdateFlag() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.sessionClient.displayName = { "회원" }
            $0.appConfigClient.isUpdateAvailable = { true }
        }
        await store.send(.onAppear) {
            $0.nickname = "회원"
            $0.isUpdateAvailable = true
        }
    }

    @Test("최신 버전이면 업데이트 가용 플래그가 false")
    func onAppearUpToDate() async {
        let store = TestStore(initialState: ProfileFeature.State()) {
            ProfileFeature()
        } withDependencies: {
            $0.sessionClient.displayName = { "회원" }
            $0.appConfigClient.isUpdateAvailable = { false }
        }
        await store.send(.onAppear) {
            $0.nickname = "회원"
        }
    }
}
