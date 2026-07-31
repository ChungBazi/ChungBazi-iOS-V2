// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

public enum BaziFont: CaseIterable {
    // MARK: - Head (140% line height)
    case head28B
    case head24B
    case head22B
    case head20B
    case head18B

    // MARK: - Body (140% line height)
    case body16B
    case body16SB
    case body16M
    case body16R
    case body15SB

    // MARK: - Small (140% line height)
    case small14SB
    case small14R
    case small12SB
    case small12M
    case small12R

    // MARK: - NaviBar (absolute 11px line height)
    case navi11SB
    case navi11M
    case navi10SB

    // MARK: - Properties

    public var size: CGFloat {
        switch self {
        case .head28B:                          return 28
        case .head24B:                          return 24
        case .head22B:                          return 22
        case .head20B:                          return 20
        case .head18B:                          return 18
        case .body16B, .body16SB,
             .body16M, .body16R:               return 16
        case .body15SB:                         return 15
        case .small14SB, .small14R:             return 14
        case .small12SB, .small12M, .small12R:  return 12
        case .navi11SB, .navi11M:               return 11
        case .navi10SB:                         return 10
        }
    }

    public var lineHeight: CGFloat {
        switch self {
        // NaviBar: absolute 11px
        case .navi11SB, .navi11M, .navi10SB:    return 11
        // Others: size × 140%
        default:                                 return size * 1.4
        }
    }

    public var letterSpacing: CGFloat { 0 }

    public var lineSpacing: CGFloat { max(lineHeight - size, 0) }

    public var font: Font {
        Self.registerFontsOnce
        return .custom(postScriptName, size: size)
    }

    /// UIKit(예: `UIPickerView` 델리게이트)에서 직접 라벨 스타일을 줘야 할 때 쓰는 변환.
    public var uiFont: UIFont {
        Self.registerFontsOnce
        return UIFont(name: postScriptName, size: size) ?? .systemFont(ofSize: size)
    }

    /// 처음 `.font`에 접근하는 시점에 단 한 번만 폰트를 등록한다.
    private static let registerFontsOnce: Void = {
        FontRegistrator.registerFonts()
    }()

    private var postScriptName: String {
        switch self {
        case .head28B, .head24B, .head22B, .head20B, .head18B, .body16B:
            return "Pretendard-Bold"
        case .body16SB, .body15SB,
             .small14SB, .small12SB,
             .navi11SB, .navi10SB:
            return "Pretendard-SemiBold"
        case .body16M, .small12M, .navi11M:
            return "Pretendard-Medium"
        case .body16R, .small14R, .small12R:
            return "Pretendard-Regular"
        }
    }
}
