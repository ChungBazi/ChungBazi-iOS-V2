// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation

@MainActor
struct NotificationSettingFeatureTests {

    @Test("진입 시 설정 조회에 성공하면 값이 채워지고 hasLoaded=true가 된다")
    func onAppear_success_setsValuesAndHasLoaded() async {
        let settings = NotificationSettings(isAllOn: false, isMyPolicyOn: false, isChungBaziOn: true)
        let store = TestStore(initialState: NotificationSettingFeature.State()) {
            NotificationSettingFeature()
        } withDependencies: {
            $0.notificationSettingClient.getSettings = { settings }
        }

        // 초기 hasLoaded는 false라 onAppear의 리셋은 상태를 바꾸지 않는다.
        await store.send(.onAppear)
        await store.receive(.settingsResponse(.success(settings))) {
            $0.isAllNotificationOn = false
            $0.isMyPolicyNotificationOn = false
            $0.isChungBaziNotificationOn = true
            $0.hasLoaded = true
        }
    }

    @Test("진입 시 조회에 실패하면 hasLoaded=false로 남고 경고 토스트가 뜬다")
    func onAppear_failure_keepsHasLoadedFalse() async {
        let store = TestStore(initialState: NotificationSettingFeature.State()) {
            NotificationSettingFeature()
        } withDependencies: {
            $0.notificationSettingClient.getSettings = { throw UseCaseError.offline }
        }

        await store.send(.onAppear)
        await store.receive(.settingsResponse(.failure(.offline))) {
            $0.errorToast = UseCaseError.offline.toastMessage
        }
        #expect(store.state.hasLoaded == false)
    }

    @Test("이전 조회 성공 후 재조회가 실패하면 hasLoaded=false로 내려가 토글이 잠긴다")
    func refetch_failure_resetsHasLoaded() async {
        var state = NotificationSettingFeature.State()
        state.hasLoaded = true
        let store = TestStore(initialState: state) {
            NotificationSettingFeature()
        } withDependencies: {
            $0.notificationSettingClient.getSettings = { throw UseCaseError.offline }
        }

        // 재조회 시작 시점에 hasLoaded를 내려, 오래된 값으로 저장하는 것을 막는다.
        await store.send(.onAppear) {
            $0.hasLoaded = false
        }
        await store.receive(.settingsResponse(.failure(.offline))) {
            $0.errorToast = UseCaseError.offline.toastMessage
        }
    }
}
