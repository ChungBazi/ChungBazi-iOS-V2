import SwiftUI

public extension View {
    func baziFont(_ style: BaziFont) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .kerning(style.letterSpacing)
            .padding(.vertical, style.lineSpacing / 2)
    }
}
