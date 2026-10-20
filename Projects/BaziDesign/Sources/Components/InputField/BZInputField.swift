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
    /// 현재(기존) 닉네임. 입력값이 이 값과 같으면 "현재 사용 중인 닉네임" 안내를 표시한다.
    private let currentNickname: String?

    @FocusState private var isFocused: Bool

    // MARK: - Init

    public init(
        text: Binding<String>,
        placeholder: String,
        maxLength: Int = BZInputField.defaultMaxLength,
        minLength: Int = BZInputField.defaultMinLength,
        currentNickname: String? = nil
    ) {
        self._text = text
        self.placeholder = placeholder
        self.maxLength = maxLength
        self.minLength = minLength
        self.currentNickname = currentNickname
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
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(Color.gray200))
                .focused($isFocused)
                .baziFont(.body16R)
                .foregroundColor(Color.grayBlack)
                .accessibilityLabel(placeholder)
                // 검증 문구는 힌트로 제공한다(value로 두면 입력값이 가려짐).
                .accessibilityHint(helperText)

            Text("\(text.count)/\(maxLength)")
                .baziFont(.small12M)
                .foregroundColor(Color.gray400)
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .baziBackground(.bgWhite)
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

    /// 공백만 입력된 경우 실제 글자 수로 취급하지 않기 위해 다듬은(trim) 길이를 쓴다.
    private var trimmedLength: Int {
        text.trimmingCharacters(in: .whitespacesAndNewlines).count
    }

    /// 입력은 했지만 최소 길이 미만인 상태(에러 문구를 보여줘야 함)
    private var isTooShort: Bool { !text.isEmpty && trimmedLength < minLength }

    private var isValid: Bool { trimmedLength >= minLength }

    /// 유효하면서 현재(기존) 닉네임과 동일한 상태. 변경 없이 저장할 수 없음을 안내한다.
    private var isCurrent: Bool {
        guard let currentNickname, isValid else { return false }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
            == currentNickname.trimmingCharacters(in: .whitespacesAndNewlines)
    }
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
        if isCurrent {
            return Color.bazi(.primary)
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
        if isCurrent {
            return "현재 사용 중인 닉네임이에요"
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
