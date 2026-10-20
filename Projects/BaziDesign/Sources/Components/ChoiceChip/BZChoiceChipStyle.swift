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
            // 고정 높이(50) 칩이라 큰 글자에서 라벨이 "…" 잘리지 않도록 칸에 맞게 축소.
            .lineLimit(1)
            .minimumScaleFactor(0.6)
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
