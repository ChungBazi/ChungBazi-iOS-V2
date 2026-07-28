// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct BZButtonStyle: ButtonStyle {

    // MARK: - Properties

    let type: BZButtonType
    let size: BZButtonSize

    // MARK: - Body

    func makeBody(configuration: Configuration) -> some View {
        BZButtonStyleBody(configuration: configuration, type: type, size: size)
    }
}

// MARK: - BZButtonStyleBody

private struct BZButtonStyleBody: View {

    // MARK: - Properties

    @Environment(\.isEnabled) private var isEnabled

    let configuration: BZButtonStyle.Configuration
    let type: BZButtonType
    let size: BZButtonSize

    // MARK: - Body

    var body: some View {
        configuration.label
            .baziFont(.body16SB)
            .foregroundColor(foregroundColor)
            .frame(width: size.fixedWidth, height: 52)
            .frame(maxWidth: size.fixedWidth == nil ? .infinity : nil)
            .background(backgroundColor)
            .overlay {
                if let borderColor {
                    RoundedRectangle(cornerRadius: BaziRadius.medium.rawValue, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 0.8)
                }
            }
            .baziRadius(.medium)
    }
}

// MARK: - Colors

extension BZButtonStyleBody {

    private var isPressed: Bool { configuration.isPressed }

    private var backgroundColor: Color {
        guard isEnabled else { return BaziDesignAsset.gray200.swiftUIColor }

        switch type {
        case .cta:
            return isPressed ? BaziDesignAsset.blue800.swiftUIColor : BaziColor.primary.color
        case .normal, .normal2:
            return isPressed ? BaziDesignAsset.gray400.swiftUIColor : BaziColor.bgWhite.color
        case .accent:
            return BaziColor.accent.color
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return BaziDesignAsset.gray400.swiftUIColor }

        switch type {
        case .cta, .accent:
            return isPressed ? BaziDesignAsset.gray300.swiftUIColor : BaziColor.bgWhite.color
        case .normal, .normal2:
            return BaziDesignAsset.gray700.swiftUIColor
        }
    }

    private var borderColor: Color? {
        guard type == .normal else { return nil }
        guard isEnabled else { return BaziDesignAsset.gray200.swiftUIColor }
        return isPressed ? BaziDesignAsset.gray400.swiftUIColor : BaziDesignAsset.gray200.swiftUIColor
    }
}
