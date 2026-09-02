// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

/// `UIPickerView` 기반 단일 열 커스텀 피커. 선택 행과 멀어질수록 폰트·색상이 옅어진다.
/// 처음엔 선택 행이 `grayBlack`, 값을 옮기면 `primary`로 바뀐다. 라벨/조합은 호출부 책임.
public struct BZDatePicker: UIViewRepresentable {

    private static let rowHeight: CGFloat = 48
    /// 호출부가 폭을 제안하지 않을 때 쓰는 기본 폭(단일 열 기준).
    private static let defaultWidth: CGFloat = 80

    /// 호출부의 `.frame(height:)`에 그대로 써서 5줄(선택 위/아래 2줄씩)이 보이게 한다.
    public static let height: CGFloat = rowHeight * 5

    @Binding private var selection: Int
    private let range: ClosedRange<Int>
    private let text: (Int) -> String

    public init(selection: Binding<Int>, range: ClosedRange<Int>, text: @escaping (Int) -> String) {
        self._selection = selection
        self.range = range
        self.text = text
    }

    public func makeUIView(context: Context) -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.dataSource = context.coordinator
        pickerView.delegate = context.coordinator
        pickerView.selectRow(selection - range.lowerBound, inComponent: 0, animated: false)
        hideSelectionIndicator(in: pickerView)
        return pickerView
    }

    public func updateUIView(_ pickerView: UIPickerView, context: Context) {
        context.coordinator.parent = self

        // 행 재구성(reload) 후에 선택 행을 지정한다. 순서를 바꾸면 reload가 물리적 위치를 리셋할 수 있다.
        pickerView.reloadAllComponents()
        let targetRow = selection - range.lowerBound
        if pickerView.selectedRow(inComponent: 0) != targetRow {
            pickerView.selectRow(targetRow, inComponent: 0, animated: false)
        }
        hideSelectionIndicator(in: pickerView)
    }

    public func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    /// `UIPickerView`의 intrinsic 크기(넓은 고정 폭)를 그대로 쓰면 `HStack`에서 `.frame(maxWidth: .infinity)` 컬럼이 균등 분배되지 않고 한쪽이 다 차지해버린다.
    /// 호출부가 제안하는 크기를 그대로 받아들이도록 오버라이드한다.
    public func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIPickerView, context: Context) -> CGSize? {
        CGSize(width: proposal.width ?? Self.defaultWidth, height: proposal.height ?? Self.height)
    }

    /// `UIPickerView`의 두 번째 서브뷰가 선택 행 위아래 구분선을 그리는 오버레이라 배경을 지우면 사라진다.
    private func hideSelectionIndicator(in pickerView: UIPickerView) {
        guard pickerView.subviews.count > 1 else { return }
        pickerView.subviews[1].backgroundColor = .clear
    }
}

// MARK: - Coordinator

extension BZDatePicker {

    public final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {

        var parent: BZDatePicker
        private var hasInteracted = false

        init(parent: BZDatePicker) {
            self.parent = parent
        }

        public func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

        public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.range.count
        }

        public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            BZDatePicker.rowHeight
        }

        public func pickerView(
            _ pickerView: UIPickerView,
            viewForRow row: Int,
            forComponent component: Int,
            reusing view: UIView?
        ) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            label.text = parent.text(parent.range.lowerBound + row)
            label.textAlignment = .center

            // 강조(선택) 행은 UIPickerView 내부 selectedRow(reload 시 리셋될 수 있음)가 아니라
            // 바인딩 값(selection)을 기준으로 계산해, 재진입 후에도 선택 행이 어긋나지 않게 한다.
            let selectedRow = parent.selection - parent.range.lowerBound
            let distance = abs(row - selectedRow)
            let style = BZDatePicker.rowStyle(distance: distance, hasInteracted: hasInteracted)
            label.font = style.font
            label.textColor = style.color
            return label
        }

        public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            hasInteracted = true
            parent.selection = parent.range.lowerBound + row
            pickerView.reloadAllComponents()
        }
    }
}

// MARK: - Row Style

extension BZDatePicker {

    private static func rowStyle(distance: Int, hasInteracted: Bool) -> (font: UIFont, color: UIColor) {
        switch distance {
        case 0:
            let color = hasInteracted ? Color.bazi(.primary) : Color.grayBlack
            return (BaziFont.head22B.uiFont, UIColor(color))
        case 1:
            return (BaziFont.body16R.uiFont, UIColor(Color.gray600))
        default:
            return (BaziFont.body16R.uiFont, UIColor(Color.gray500))
        }
    }
}

// MARK: - Preview

private struct BZDatePickerPreview: View {
    @State private var year = 2000

    var body: some View {
        BZDatePicker(selection: $year, range: 1926...2026) { "\($0)" }
            .frame(height: BZDatePicker.height)
    }
}

#Preview {
    BZDatePickerPreview()
}
