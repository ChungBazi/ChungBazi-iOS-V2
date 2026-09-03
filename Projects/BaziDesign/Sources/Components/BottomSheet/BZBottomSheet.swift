// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct BZBottomSheet: View {

    // MARK: - Layout Constants
    // 같은 파일의 BZBottomSheetRowStyle(별도 타입)에서도 rowHeight를 참조하므로 fileprivate.

    fileprivate static let rowHeight: CGFloat = 52
    fileprivate static let dividerHeight: CGFloat = 1
    fileprivate static let bottomPadding: CGFloat = 20

    // MARK: - Properties

    private let title: String
    private let options: [String]
    private let selection: String?
    private let maxVisibleRows: Int
    private let onSelect: (String) -> Void

    /// 타이틀 높이는 폰트·패딩에 따라 달라지므로 런타임에 측정해 detent 계산에 쓴다.
    /// 초기값은 실측 근사치(70)로 두어 첫 프레임에서 시트 높이가 튀지 않게 한다.
    @State private var titleHeight: CGFloat = 70

    // MARK: - Init

    public init(
        title: String,
        options: [String],
        selection: String? = nil,
        maxVisibleRows: Int = 7,
        onSelect: @escaping (String) -> Void
    ) {
        self.title = title
        self.options = options
        self.selection = selection
        self.maxVisibleRows = maxVisibleRows
        self.onSelect = onSelect
    }

    // MARK: - Body

    public var body: some View {
        VStack(spacing: 0) {
            titleLabel
            optionList
                .padding(.bottom, Self.bottomPadding)
        }
        .baziBackground(.bgWhite)
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Subviews

extension BZBottomSheet {

    private var titleLabel: some View {
        Text(title)
            .baziFont(.body16SB)
            .foregroundColor(Color.gray900)
            .accessibilityAddTraits(.isHeader)
            .frame(maxWidth: .infinity)
            .padding(.top, 26)
            .padding(.bottom, 18)
            .background(
                // 타이틀의 실제 렌더 높이를 측정해 detent 계산의 오차(폰트/패딩 추정)를 없앤다.
                GeometryReader { proxy in
                    Color.clear
                        .onAppear { titleHeight = proxy.size.height }
                        .onChange(of: proxy.size.height) { _, newValue in
                            titleHeight = newValue
                        }
                }
            )
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
                    .accessibilityAddTraits(option == selection ? .isSelected : [])

                    if index < options.count - 1 {
                        Rectangle()
                            .fill(Color.gray100)
                            .frame(height: Self.dividerHeight)
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
        // 항목이 maxVisibleRows를 넘겨 실제로 넘칠 때만 스크롤 허용, 그 외에는 잠금.
        .scrollDisabled(!isScrollable)
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
            .frame(height: BZBottomSheet.rowHeight)
            .background(configuration.isPressed ? Color.blue50 : Color.clear)
            .contentShape(Rectangle())
    }
}

// MARK: - Layout

extension BZBottomSheet {

    /// 항목이 maxVisibleRows를 넘으면 스크롤이 필요하다.
    private var isScrollable: Bool {
        options.count > maxVisibleRows
    }

    /// 실측 타이틀 높이 + 결정적인 행/구분선/여백으로 시트 높이를 계산한다.
    /// (행 높이는 `BZBottomSheetRowStyle`이 강제하는 실제값이라 추정이 아니다.)
    private var sheetHeight: CGFloat {
        let visibleRows = min(options.count, maxVisibleRows)
        let rows = CGFloat(visibleRows) * Self.rowHeight
        let dividers = CGFloat(max(visibleRows - 1, 0)) * Self.dividerHeight
        return titleHeight + rows + dividers + Self.bottomPadding
    }

    /// 스크롤이 필요한 경우에만 .large까지 끌 수 있게 한다.
    private var detents: Set<PresentationDetent> {
        isScrollable ? [.height(sheetHeight), .large] : [.height(sheetHeight)]
    }
}

// MARK: - Preview

private struct BZBottomSheetPreview: View {
    @State private var isPresented = true

    var body: some View {
        Color.clear
            .sheet(isPresented: $isPresented) {
                BZBottomSheet(
                    title: "지역을 선택해주세요",
                    options: ["서울", "경기", "인천", "부산", "대구", "광주", "대전"]
                ) { _ in }
            }
    }
}

#Preview {
    BZBottomSheetPreview()
}
