// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public extension View {
    func baziRadius(_ radius: BaziRadius) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius.rawValue, style: .continuous))
    }
}
