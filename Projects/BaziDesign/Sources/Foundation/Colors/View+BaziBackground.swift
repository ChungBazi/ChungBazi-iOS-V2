// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public extension View {
    func baziBackground(_ color: BaziColor) -> some View {
        background(Color.bazi(color))
    }
}
