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
        guard isEnabled else { return Color.gray200 }

        switch type {
        case .cta:
            return isPressed ? Color.blue800 : Color.bazi(.primary)
        case .normal, .normal2:
            return isPressed ? Color.gray400 : Color.bazi(.bgWhite)
        case .accent:
            return Color.bazi(.accent)
        }
    }

    private var foregroundColor: Color {
        guard isEnabled else { return Color.gray400 }

        switch type {
        case .cta, .accent:
            return isPressed ? Color.gray300 : Color.bazi(.bgWhite)
        case .normal, .normal2:
            return Color.gray700
        }
    }

    private var borderColor: Color? {
        guard type == .normal else { return nil }
        guard isEnabled else { return Color.gray200 }
        return isPressed ? Color.gray400 : Color.gray200
    }
}
