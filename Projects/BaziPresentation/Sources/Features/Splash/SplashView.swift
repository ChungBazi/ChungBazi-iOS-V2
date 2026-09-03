// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

import BaziDesign
import BaziDomain
import ComposableArchitecture

public struct SplashView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<SplashFeature>

    // MARK: - Init

    public init(store: StoreOf<SplashFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
            .task { store.send(.onAppear) }
            // 백그라운드 복귀 때마다 게이트 재평가(점검 해제/버전 갱신 시 자동 진입).
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                store.send(.willEnterForeground)
            }
            // 강제 업데이트: 우회 불가 단일버튼 알럿 → 앱스토어. (게이트가 풀릴 때까지 유지)
            .baziAlert(
                isPresented: Binding(get: { store.gate == .forceUpdate }, set: { _ in }),
                title: "최신 업데이트 안내",
                message: "안정적인 서비스 사용을 위해 최신 버전으로 업데이트해 주세요",
                cancelTitle: nil,
                confirmTitle: "확인",
                showsCloseButton: false
            ) { store.send(.didTapForceUpdate) }
            // 서버 점검: 우회 불가 단일버튼 알럿 → 앱 종료.
            .baziAlert(
                isPresented: Binding(get: { maintenanceMessage != nil }, set: { _ in }),
                title: "서비스 점검 안내",
                message: maintenanceMessage ?? "",
                cancelTitle: nil,
                confirmTitle: "확인",
                showsCloseButton: false
            ) { store.send(.didTapMaintenanceConfirm) }
    }

    /// 점검 게이트일 때의 메시지(그 외에는 nil → 알럿 미노출).
    private var maintenanceMessage: String? {
        if case .maintenance(let message) = store.gate { return message }
        return nil
    }
}

// MARK: - Subviews

extension SplashView {

    private var content: some View {
        ZStack {
            Color.bazi(.primary)
            phaseContent
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var phaseContent: some View {
        switch store.phase {
        case .tagline:
            taglineText

        case .logo:
            logoImage
        }
    }

    private var taglineText: some View {
        Text("청년정책 바로 지금")
            .baziFont(.head28B)
            .foregroundStyle(Color.grayWhite)
    }

    private var logoImage: some View {
        Image.bazi(.appLogo)
            .resizable()
            .scaledToFit()
            .frame(width: 100)
            .foregroundStyle(Color.grayWhite)
    }
}

// MARK: - Preview

#Preview {
    SplashView(
        store: Store(initialState: .init()) {
            SplashFeature()
        }
    )
}

#Preview("강제 업데이트") {
    SplashView(
        store: Store(initialState: .init()) {
            SplashFeature()
        } withDependencies: {
            $0.appConfigClient.evaluateGate = { .forceUpdate }
        }
    )
}

#Preview("서버 점검") {
    SplashView(
        store: Store(initialState: .init()) {
            SplashFeature()
        } withDependencies: {
            $0.appConfigClient.evaluateGate = { .maintenance(message: "안정적인 서비스 제공을 위해 시스템 점검 중입니다.") }
        }
    )
}
