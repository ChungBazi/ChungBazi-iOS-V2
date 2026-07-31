// Copyright © 2026 ChungBazi. All rights reserved.

import BaziData
import BaziPresentation
import ComposableArchitecture
import SwiftUI

@main
struct ChungBaziApp: App {
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
        }
    }
}
