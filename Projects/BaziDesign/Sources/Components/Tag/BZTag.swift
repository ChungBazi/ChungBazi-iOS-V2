// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public enum BZTagType {
    case green
    case blue100
    case blue200

    var backgroundColor: Color {
        switch self {
        case .green: return .green300
        case .blue100: return .blue100
        case .blue200: return .blue200
        }
    }

    var textColor: Color {
        switch self {
        case .green: return .grayBlack80
        case .blue100, .blue200: return .gray800
        }
    }
}

public struct BZTag: View {

    // MARK: - Properties

    private let text: String
    private let type: BZTagType

    // MARK: - Init

    public init(_ text: String, type: BZTagType = .blue100) {
        self.text = text
        self.type = type
    }

    // MARK: - Body

    public var body: some View {
        Text(text)
            .baziFont(.small12M)
            .foregroundStyle(type.textColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(type.backgroundColor)
            .baziRadius(.small)
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 8) {
        BZTag("텍스트", type: .green)
        BZTag("텍스트", type: .blue100)
        BZTag("텍스트", type: .blue200)
    }
    .padding()
}
