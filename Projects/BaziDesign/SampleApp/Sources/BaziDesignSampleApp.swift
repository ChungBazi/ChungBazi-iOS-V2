import BaziDesign
import SwiftUI

@main
struct BaziDesignSampleApp: App {
    init() {
        FontRegistrator.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            Text("BaziDesign Sample")
        }
    }
}
