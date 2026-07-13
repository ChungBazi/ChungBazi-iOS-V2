import SwiftUI

public extension View {
    func baziForeground(_ color: BaziColor) -> some View {
        foregroundColor(color.color)
    }

    func baziBackground(_ color: BaziColor) -> some View {
        background(color.color)
    }
}
