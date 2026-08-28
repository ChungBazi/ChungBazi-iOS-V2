// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziCore

/// 생년월일(년/월/일) 3열 휠 피커. 온보딩·프로필 등에서 공유한다.
/// 일 범위는 선택된 연/월의 실제 일수로 계산한다. (day 값 클램핑은 상태를 소유한 Reducer가 담당한다.)
public struct BZBirthDatePicker: View {

    @Binding private var year: Int
    @Binding private var month: Int
    @Binding private var day: Int

    private static let minYear = 1926
    private static var maxYear: Int { Calendar.current.component(.year, from: Date()) }

    public init(year: Binding<Int>, month: Binding<Int>, day: Binding<Int>) {
        self._year = year
        self._month = month
        self._day = day
    }

    public var body: some View {
        HStack(spacing: 0) {
            column(label: "년") {
                BZDatePicker(selection: $year, range: Self.minYear...Self.maxYear) { "\($0)" }
            }
            column(label: "월") {
                BZDatePicker(selection: $month, range: 1...12) { String(format: "%02d", $0) }
            }
            column(label: "일") {
                BZDatePicker(selection: $day, range: 1...CalendarUtil.daysInMonth(year: year, month: month)) {
                    String(format: "%02d", $0)
                }
            }
        }
    }

    private func column(label: String, @ViewBuilder picker: () -> some View) -> some View {
        VStack(spacing: 8) {
            Text(label)
                .baziFont(.small12M)
                .foregroundStyle(Color.gray700)
            picker()
                .frame(height: BZDatePicker.height)
        }
        .frame(maxWidth: .infinity)
    }
}
