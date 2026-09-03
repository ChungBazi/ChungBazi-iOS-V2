// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture
import Testing

import BaziDomain
@testable import BaziPresentation
import Foundation

@MainActor
struct SplashFeatureTests {

    /// 최소시간·세션은 이미 끝난 상태에서 게이트만 검증하기 위한 준비 상태.
    private func readyState(gate: AppLaunchGate? = nil) -> SplashFeature.State {
        var state = SplashFeature.State()
        state.isMinimumDurationElapsed = true
        state.sessionResult = .init(hasValidToken: true, hasNickname: false, hasCompletedOnboarding: false)
        state.gate = gate
        return state
    }

    @Test("정상 게이트 + 최소시간·세션 완료면 스플래시를 종료한다")
    func normalGateFinishes() async {
        let store = TestStore(initialState: readyState()) { SplashFeature() }
        await store.send(.gateResolved(.normal)) { $0.gate = .normal }
        await store.receive(\.delegate.didFinishSplash)
    }

    @Test("점검 게이트면 gate에 반영되고 스플래시 종료 delegate가 없다")
    func maintenanceGateBlocks() async {
        let store = TestStore(initialState: readyState()) { SplashFeature() }
        await store.send(.gateResolved(.maintenance(message: "점검중"))) {
            $0.gate = .maintenance(message: "점검중")
        }
    }

    @Test("강제 업데이트 확인 시 앱스토어로 이동한다")
    func forceUpdateOpensAppStore() async {
        let opened = LockIsolated<URL?>(nil)
        let store = TestStore(initialState: readyState(gate: .forceUpdate)) {
            SplashFeature()
        } withDependencies: {
            $0.openURL = .init { url in opened.setValue(url); return true }
        }
        await store.send(.didTapForceUpdate)
        await store.finish()
        #expect(opened.value == ProfileConstants.appStoreURL)
    }

    @Test("점검 확인 시 앱을 종료한다")
    func maintenanceConfirmExits() async {
        let exited = LockIsolated(false)
        let store = TestStore(initialState: readyState(gate: .maintenance(message: "점검"))) {
            SplashFeature()
        } withDependencies: {
            $0.exitApp = { exited.setValue(true) }
        }
        await store.send(.didTapMaintenanceConfirm)
        await store.finish()
        #expect(exited.value)
    }
}
