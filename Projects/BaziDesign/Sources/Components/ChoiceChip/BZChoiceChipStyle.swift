// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct BZChoiceChipStyle: ButtonStyle {

    // MARK: - Properties

    let isSelected: Bool

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .baziFont(isSelected ? .body16SB : .body16R)
            .foregroundColor(isSelected ? Color.bazi(.primary) : Color.gray700)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(isSelected ? Color.blue100 : Color.bazi(.bgWhite))
            .overlay(
                RoundedRectangle(cornerRadius: BaziRadius.medium.rawValue, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.bazi(.primary) : Color.gray200,
                        lineWidth: 0.8
                    )
            )
            .baziRadius(.medium)
    }
}
