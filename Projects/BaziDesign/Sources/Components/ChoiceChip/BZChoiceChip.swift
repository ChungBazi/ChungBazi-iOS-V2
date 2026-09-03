// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct BZChoiceChip: View {

    // MARK: - Properties

    private let title: String
    private let isSelected: Bool
    private let action: () -> Void

    // MARK: - Init

    public init(
        _ title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            Text(title)
        }
        .buttonStyle(BZChoiceChipStyle(isSelected: isSelected))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: 12) {
        BZChoiceChip("취업·창업", isSelected: false) {}
        BZChoiceChip("월세·주거", isSelected: true) {}
    }
    .padding(20)
}
