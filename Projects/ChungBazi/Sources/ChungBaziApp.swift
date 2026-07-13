import BaziDesign
import SwiftUI

@main
struct ChungBaziApp: App {
    init() {
        FontRegistrator.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
