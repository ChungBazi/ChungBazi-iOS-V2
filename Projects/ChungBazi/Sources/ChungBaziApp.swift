// Copyright © 2026 ChungBazi. All rights reserved.

import BaziData
import BaziPresentation
import BaziStorage
import ComposableArchitecture
import KakaoSDKAuth
import SwiftUI

@main
struct ChungBaziApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        DataConfiguration.configure(baseURL: Config.baseURL)
        // 다른 서버에서 발급된 토큰이 남아 있으면 첫 요청 전에 폐기한다.
        if let host = URL(string: Config.baseURL)?.host {
            SessionHostGuard(tokenStorage: KeychainTokenStorage()).bind(to: host)
        }
    }

    var body: some Scene {
        WindowGroup {
            AppView(
                store: Store(initialState: .splash(SplashFeature.State())) {
                    AppFeature()
                }
            )
            .onOpenURL { url in
                if AuthApi.isKakaoTalkLoginUrl(url) {
                    _ = AuthController.handleOpenUrl(url: url)
                } else if let policyId = KakaoLinkParser.policyId(from: url) {
                    DeeplinkPublisher.policyDetail(id: policyId)
                } else if let policyId = PolicyDeeplink.policyId(from: url) {
                    // 캘린더 이벤트 URL({앱 스킴}://policy/{id}) 탭 → 정책 상세.
                    DeeplinkPublisher.policyDetail(id: policyId)
                }
            }
        }
    }
}
