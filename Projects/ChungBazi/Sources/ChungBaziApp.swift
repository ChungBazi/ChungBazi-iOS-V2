// Copyright © 2026 ChungBazi. All rights reserved.

import BaziData
import BaziDesign
import BaziPresentation
import SwiftUI

@main
struct ChungBaziApp: App {
    init() {
        FontRegistrator.registerFonts()
        DataConfiguration.configure(baseURL: Config.baseURL)
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorContainer()
        }
    }
}
