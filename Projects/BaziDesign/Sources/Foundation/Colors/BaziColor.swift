// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BaziColor {
    // MARK: - Brand
    case primary    // Blue/700
    case secondary  // Green/300

    // MARK: - BG
    case bgGray     // Grayscale/100
    case bgWhite    // Grayscale/White

    // MARK: - Purpose
    case accent     // Red/400
    case dim1       // Grayscale/Black45%
    case dim2       // Grayscale/Black80%

    public var color: Color {
        switch self {
        case .primary:   return Color.blue700
        case .secondary: return Color.green300
        case .bgGray:    return Color.gray100
        case .bgWhite:   return Color.grayWhite
        case .accent:    return Color.red400
        case .dim1:      return Color.grayBlack45
        case .dim2:      return Color.grayBlack80
        }
    }
}
