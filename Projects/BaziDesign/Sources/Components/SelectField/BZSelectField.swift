// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct BZSelectField: View {

    // MARK: - Properties

    private let title: String
    private let placeholder: String
    private let options: [String]
    @Binding private var selection: String?
    private let isDisabled: Bool

    @State private var isPresented = false

    // MARK: - Init

    public init(
        title: String,
        placeholder: String = "선택해주세요",
        options: [String],
        selection: Binding<String?>,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self.options = options
        self._selection = selection
        self.isDisabled = isDisabled
    }

    // MARK: - Body

    public var body: some View {
        Button {
            isPresented = true
        } label: {
            content
        }
        .disabled(isDisabled)
        .accessibilityLabel("\(title), \(selection ?? placeholder)")
        .accessibilityHint("탭하여 선택")
        .sheet(isPresented: $isPresented) {
            BZBottomSheet(title: title, options: options, selection: selection) { option in
                selection = option
                isPresented = false
            }
        }
    }
}

// MARK: - Subviews

extension BZSelectField {

    private var content: some View {
        HStack(spacing: 8) {
            Text(selection ?? placeholder)
                .baziFont(selection != nil ? .body16M : .body16R)
                .foregroundColor(textColor)

            Spacer()

            Image(systemName: isPresented ? "chevron.up" : "chevron.down")
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(chevronColor)
        }
        .padding(.horizontal, 16)
        // 고정 높이 대신 최소 높이 — 큰 글자에서 선택값이 여러 줄로 늘어나며 "…"로 잘리지 않도록.
        .frame(minHeight: 52)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: BaziRadius.medium.rawValue, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.8)
        )
        .baziRadius(.medium)
    }
}

// MARK: - Colors

extension BZSelectField {

    private var backgroundColor: Color {
        isDisabled ? Color.gray100 : Color.bazi(.bgWhite)
    }

    private var borderColor: Color {
        if isDisabled { return Color.gray200 }
        if isPresented { return Color.bazi(.primary) }
        if selection != nil { return Color.gray200 }
        return Color.gray500
    }

    private var textColor: Color {
        if isDisabled { return Color.gray300 }
        if isPresented { return Color.gray600 }
        if selection != nil { return Color.grayBlack }
        return Color.gray500
    }
    
    private var chevronColor: Color {
        if isDisabled { return Color.gray300 }
        else { return
            Color.gray700 }
    }
}

// MARK: - Preview

private struct BZSelectFieldPreview: View {
    @State private var region: String?

    var body: some View {
        VStack(spacing: 24) {
            BZSelectField(
                title: "지역을 선택해주세요",
                options: ["서울", "경기", "인천", "부산", "대구"],
                selection: $region
            )
            BZSelectField(
                title: "지역을 선택해주세요",
                options: ["서울", "경기"],
                selection: .constant(nil),
                isDisabled: true
            )
        }
        .padding(20)
    }
}

#Preview {
    BZSelectFieldPreview()
}
