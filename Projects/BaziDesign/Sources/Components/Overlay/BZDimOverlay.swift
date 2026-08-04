// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BZDimLevel {
    /// Grayscale/Black45%
    case dim1
    /// Grayscale/Black80%
    case dim2
}

/// 모달/시트 뒤에 까는 딤 처리 오버레이. (Figma: Overlay - Dim)
public struct BZDimOverlay: View {

    // MARK: - Properties

    private let level: BZDimLevel

    // MARK: - Init

    public init(level: BZDimLevel = .dim1) {
        self.level = level
    }

    // MARK: - Body

    public var body: some View {
        Color.bazi(level == .dim1 ? .dim1 : .dim2)
            .ignoresSafeArea()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.bazi(.bgWhite)
        BZDimOverlay(level: .dim1)
    }
}
