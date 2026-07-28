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

    private let maxVisibleRows = 7

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
        .sheet(isPresented: $isPresented) {
            BZBottomSheet(title: title, options: options, maxVisibleRows: maxVisibleRows) { option in
                selection = option
                isPresented = false
            }
            .presentationDetents(sheetDetents)
            .presentationDragIndicator(.visible)
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
        .frame(height: 52)
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

    private var sheetHeight: CGFloat {
        BZBottomSheet.height(forRowCount: options.count, maxVisibleRows: maxVisibleRows)
    }

    /// 옵션이 maxVisibleRows를 넘어 스크롤이 필요할 때만 .large까지 끌 수 있게 한다.
    private var sheetDetents: Set<PresentationDetent> {
        options.count > maxVisibleRows ? [.height(sheetHeight), .large] : [.height(sheetHeight)]
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
