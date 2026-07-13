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
    case dim        // Grayscale/Black45%

    public var color: Color {
        switch self {
        case .primary:   return BaziDesignAsset.blue700.swiftUIColor
        case .secondary: return BaziDesignAsset.green300.swiftUIColor
        case .bgGray:    return BaziDesignAsset.gray100.swiftUIColor
        case .bgWhite:   return BaziDesignAsset.grayWhite.swiftUIColor
        case .accent:    return BaziDesignAsset.red400.swiftUIColor
        case .dim:       return BaziDesignAsset.grayBlack45.swiftUIColor
        }
    }
}
