// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 38x38 원형 아이콘 버튼. (Figma: BTN2)
public struct BZCircleButton: View {

    // MARK: - Properties

    private let action: () -> Void

    // MARK: - Init

    public init(action: @escaping () -> Void) {
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
    }
}

// MARK: - Preview

#Preview {
    BZCircleButton {}
}
