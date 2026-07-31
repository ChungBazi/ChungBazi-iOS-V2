// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct BZBottomSheet: View {

    // MARK: - Properties

    private let title: String
    private let options: [String]
    private let onSelect: (String) -> Void

    // MARK: - Init

    public init(
        title: String,
        options: [String],
        onSelect: @escaping (String) -> Void
    ) {
        self.title = title
        self.options = options
        self.onSelect = onSelect
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            titleLabel
            optionList
                .padding(.bottom, 20)
        }
        .baziBackground(.bgWhite)
    }
}

// MARK: - Subviews

extension BZBottomSheet {

    private var titleLabel: some View {
        Text(title)
            .baziFont(.body16SB)
            .foregroundColor(Color.gray900)
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
            .padding(.bottom, 18)
    }

    private var optionList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                    Button {
                        onSelect(option)
                    } label: {
                        Text(option)
                    }
                    .buttonStyle(BZBottomSheetRowStyle())

                    if index < options.count - 1 {
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(height: 1)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - BZBottomSheetRowStyle

private struct BZBottomSheetRowStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .baziFont(configuration.isPressed ? .small14SB : .small14R)
            .foregroundColor(
                configuration.isPressed
                ? Color.grayBlack
                : Color.gray700
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .frame(height: 52)
            .background(configuration.isPressed ? Color.blue50 : Color.clear)
            .contentShape(Rectangle())
    }
}

// MARK: - Layout

extension BZBottomSheet {

    /// 행 개수에 맞는 시트 높이를 계산한다. `.presentationDetents`에 그대로 사용한다.
    /// BZBottomSheet 자체는 항상 모든 행을 ScrollView로 렌더링하므로,
    /// 실제 보이는 행 수 제한은 이 높이를 시트의 detent로 잠그는 방식으로만 이뤄진다.
    public static func height(forRowCount rowCount: Int, maxVisibleRows: Int = 7) -> CGFloat {
        let titleHeight: CGFloat = 62
        let rowHeight: CGFloat = 52
        let borderHeight: CGFloat = 1
        let bottomPadding: CGFloat = 20
        let visibleRows = CGFloat(max(0, min(rowCount, maxVisibleRows)))
        let dividerCount = max(visibleRows - 1, 0)
        return titleHeight + visibleRows * rowHeight + dividerCount * borderHeight + bottomPadding
    }
}

// MARK: - Preview

#Preview {
    BZBottomSheet(
        title: "지역을 선택해주세요",
        options: ["서울", "경기", "인천", "부산", "대구", "광주", "대전"]
    ) { _ in }
        .presentationCornerRadius(BaziRadius.large.rawValue)
}
