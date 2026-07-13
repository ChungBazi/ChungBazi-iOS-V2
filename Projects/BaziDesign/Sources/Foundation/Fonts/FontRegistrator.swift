import CoreText
import Foundation

public enum FontRegistrator {
    public static func registerFonts() {
        let extensions = ["otf", "ttf"]
        let fontURLs = extensions.flatMap {
            Bundle.module.urls(forResourcesWithExtension: $0, subdirectory: "Fonts") ?? []
        }
        fontURLs.forEach { CTFontManagerRegisterFontsForURL($0 as CFURL, .process, nil) }
    }
}
