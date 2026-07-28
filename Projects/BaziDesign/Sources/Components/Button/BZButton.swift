// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BZButtonType {
    case cta
    case normal
    case normal2
    case accent
}

public enum BZButtonSize {
    case small
    case medium
    case large

    var fixedWidth: CGFloat? {
        switch self {
        case .small:  return 106
        case .medium: return 219
        case .large:  return nil // 부모 너비를 꽉 채움
        }
    }
}

public struct BZButton: View {

    // MARK: - Properties

    private let title: String
    private let type: BZButtonType
    private let size: BZButtonSize
    private let action: () -> Void

    // MARK: - Init

    public init(
        _ title: String,
        type: BZButtonType = .cta,
        size: BZButtonSize = .large,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.type = type
        self.size = size
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(BZButtonStyle(type: type, size: size))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        BZButton("버튼", type: .cta) {}
        BZButton("버튼", type: .normal) {}
        BZButton("버튼", type: .normal2) {}
        BZButton("버튼", type: .accent) {}
        BZButton("버튼", type: .cta) {}
            .disabled(true)

        HStack(spacing: 10) {
            BZButton("버튼", type: .normal, size: .small) {}
            BZButton("버튼", type: .cta, size: .medium) {}
        }
    }
    .padding(20)
}
