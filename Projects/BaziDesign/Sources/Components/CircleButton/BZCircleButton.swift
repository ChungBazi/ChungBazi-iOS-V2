// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 38x38 원형 아이콘 버튼. (Figma: BTN2)
public struct BZCircleButton: View {

    // MARK: - Properties

    private let accessibilityLabel: String
    private let action: () -> Void

    // MARK: - Init

    public init(accessibilityLabel: String, action: @escaping () -> Void) {
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .frame(width: 38, height: 38)
                .background(Color.bazi(.primary))
                .clipShape(Circle())
        }
        .accessibilityLabel(accessibilityLabel)
    }
}

// MARK: - Preview

#Preview {
    BZCircleButton(accessibilityLabel: "다음") {}
}
