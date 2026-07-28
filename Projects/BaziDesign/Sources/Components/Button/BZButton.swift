// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BZButtonType {
    case cta
    case normal
    case normal2
    case accent
}

public enum BZButtonSize {
    /// 고정 106pt — 다른 버튼과 짝지어 쓰는 보조 액션
    case small
    /// 남는 너비를 채움 — small과 짝지어 쓸 때의 주 액션.
    case medium
    /// 전체 너비를 채움 — 단독으로 쓸 때의 주 액션
    case large

    var fixedWidth: CGFloat? {
        self == .small ? 106 : nil
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
