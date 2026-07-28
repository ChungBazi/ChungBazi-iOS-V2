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
        case .primary:   return BaziDesignAsset.blue700.swiftUIColor
        case .secondary: return BaziDesignAsset.green300.swiftUIColor
        case .bgGray:    return BaziDesignAsset.gray100.swiftUIColor
        case .bgWhite:   return BaziDesignAsset.grayWhite.swiftUIColor
        case .accent:    return BaziDesignAsset.red400.swiftUIColor
        case .dim1:      return BaziDesignAsset.grayBlack45.swiftUIColor
        case .dim2:      return BaziDesignAsset.grayBlack80.swiftUIColor
        }
    }
}
