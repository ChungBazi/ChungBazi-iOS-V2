// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 상단 nav bar가 아니라, 타이틀 + 화살표로 이루어진 전체 탭 가능한 행.
/// 화면 내부에서 다른 화면으로 이동하는 진입점(row) 용도로 쓴다.
public struct BZNavigationRowHeader: View {

    // MARK: - Properties

    private let title: String
    private let action: () -> Void

    // MARK: - Init

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    // MARK: - Body

    public var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Subviews

extension BZNavigationRowHeader {

    private var content: some View {
        HStack(spacing: 12) {
            Text(title)
                .baziFont(.head20B)
                .foregroundStyle(Color.gray900)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.gray600)

            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .baziBackground(.bgWhite)
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview {
    BZNavigationRowHeader(title: "타이틀") {}
}
