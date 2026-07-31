// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

/// 닉네임 입력 전용 필드. 2자 미만이면 에러 상태를 스스로 표시한다.
public struct BZInputField: View {

    // MARK: - Length

    public nonisolated static let defaultMinLength = 2
    public nonisolated static let defaultMaxLength = 10

    // MARK: - Properties

    @Binding private var text: String
    private let placeholder: String
    private let maxLength: Int
    private let minLength: Int

    @FocusState private var isFocused: Bool

    // MARK: - Init

    public init(
        text: Binding<String>,
        placeholder: String,
        maxLength: Int = BZInputField.defaultMaxLength,
        minLength: Int = BZInputField.defaultMinLength
    ) {
        self._text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.minLength = minLength
    }

    // MARK: - Body

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            fieldContainer
            helperLabel
        }
        .onChange(of: text) { _, newValue in
            if newValue.count > maxLength {
                text = String(newValue.prefix(maxLength))
            }
        }
    }
}

// MARK: - Subviews

extension BZInputField {

    private var fieldContainer: some View {
        HStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .focused($isFocused)
                .baziFont(.body16R)
                .foregroundColor(Color.grayBlack)

            Text("\(text.count)/\(maxLength)")
                .baziFont(.small12M)
                .foregroundColor(Color.gray400)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(Color.bazi(.bgWhite))
        .overlay(
            RoundedRectangle(cornerRadius: BaziRadius.medium.rawValue, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.8)
        )
        .baziRadius(.medium)
    }

    private var helperLabel: some View {
        Text(helperText)
            .baziFont(.small12M)
            .foregroundColor(helperColor)
    }
}

// MARK: - Validation

extension BZInputField {

    /// 입력은 했지만 최소 길이 미만인 상태(에러 문구를 보여줘야 함)
    private var isTooShort: Bool { !text.isEmpty && text.count < minLength }

    private var isValid: Bool { text.count >= minLength }
}

// MARK: - Colors & Text

extension BZInputField {

    private var borderColor: Color {
        if isTooShort {
            return Color.bazi(.accent)
        }
        if isFocused {
            return Color.bazi(.primary)
        }
        if isValid {
            return Color.gray200
        }
        return Color.gray600
    }

    private var helperColor: Color {
        if isTooShort {
            return Color.bazi(.accent)
        }
        if isValid {
            return Color.bazi(.primary)
        }
        return Color.gray400
    }

    private var helperText: String {
        if isTooShort {
            return "\(minLength)자 이상 입력해주세요"
        }
        if isValid {
            return "사용 가능한 닉네임이에요"
        }
        return "\(minLength)자 이상 \(maxLength)자 이하로 입력해주세요"
    }
}

// MARK: - Preview

private struct BZInputFieldPreview: View {
    @State private var text = ""

    var body: some View {
        BZInputField(text: $text, placeholder: "닉네임을 입력해주세요")
            .padding(20)
    }
}

#Preview {
    BZInputFieldPreview()
}
