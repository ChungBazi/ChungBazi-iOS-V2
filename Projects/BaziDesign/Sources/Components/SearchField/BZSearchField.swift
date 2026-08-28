// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct BZSearchField: View {

    // MARK: - Properties

    @Binding private var text: String
    private let placeholder: String
    private let onSubmit: () -> Void
    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Init

    public init(
        text: Binding<String>,
        placeholder: String = "정책이나 관심 키워드를 검색해보세요",
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    public var body: some View {
        HStack(spacing: 0) {
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundColor(Color.gray400)
            )
            .baziFont(.small14R)
            .foregroundColor(Color.grayBlack)
            .submitLabel(.search)
            .onSubmit(onSubmit)

            Spacer()

            if isEnabled, !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray400)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("검색어 지우기")
            } else {
                Image.bazi(.searchIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16)
                    .accessibilityHidden(true)
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .baziBackground(.bgWhite)
        .baziRadius(.small)
    }
}

// MARK: - Preview

private struct BZSearchFieldPreview: View {
    @State private var text = ""

    var body: some View {
        BZSearchField(text: $text)
            .padding(20)
            .baziBackground(.bgGray)
    }
}

#Preview {
    BZSearchFieldPreview()
}
