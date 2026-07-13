// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign
import BaziPresentation
import SwiftUI

@main
struct ChungBaziApp: App {
    init() {
        FontRegistrator.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorContainer()
        }
    }
}
