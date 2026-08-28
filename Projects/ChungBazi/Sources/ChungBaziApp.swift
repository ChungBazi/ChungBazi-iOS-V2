// Copyright © 2026 ChungBazi. All rights reserved.

import BaziData
import BaziPresentation
import ComposableArchitecture
import KakaoSDKAuth
import SwiftUI

@main
struct ChungBaziApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    init() {
        DataConfiguration.configure(baseURL: Config.baseURL)
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
                }
            }
        }
    }
}
