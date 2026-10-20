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

    @Test("포그라운드 복귀 시 점검이 해제되면 게이트가 풀려 스플래시를 종료한다")
    func foregroundRecheckRecovers() async {
        let store = TestStore(initialState: readyState(gate: .maintenance(message: "점검"))) {
            SplashFeature()
        } withDependencies: {
            $0.appConfigClient.evaluateGate = { .normal }
        }
        await store.send(.willEnterForeground)
        await store.receive(\.gateResolved) { $0.gate = .normal }
        await store.receive(\.delegate.didFinishSplash)
    }

    @Test("포그라운드 재평가 중 이전 게이트 평가가 늦게 끝나도 최신 결과만 반영된다")
    func staleGateEvaluationDoesNotOverride() async {
        let clock = TestClock()
        let callCount = LockIsolated(0)
        let store = TestStore(initialState: readyState(gate: .maintenance(message: "점검"))) {
            SplashFeature()
        } withDependencies: {
            $0.continuousClock = clock
            $0.appConfigClient.evaluateGate = {
                let n = callCount.withValue { $0 += 1; return $0 }
                if n == 1 {
                    // 이전(느린) 평가 — cancelInFlight로 취소되어야 하며, 결과가 반영되면 안 된다.
                    try? await clock.sleep(for: .seconds(5))
                    return .maintenance(message: "점검")
                }
                // 최신(빠른) 평가 — 점검 해제.
                return .normal
            }
        }
        store.exhaustivity = .off
        await store.send(.willEnterForeground)          // 이전 평가 시작(대기 중)
        await store.send(.willEnterForeground)          // cancelInFlight → 이전 취소, 최신 .normal 반영
        await clock.advance(by: .seconds(5))            // 이전 평가 대기시간 경과(취소됐으면 무반영)
        await store.skipReceivedActions()
        #expect(store.state.gate == .normal)
    }
}
