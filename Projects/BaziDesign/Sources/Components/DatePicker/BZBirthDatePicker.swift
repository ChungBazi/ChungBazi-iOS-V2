// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import BaziCore

/// 생년월일(년/월/일) 3열 휠 피커. 온보딩·프로필 등에서 공유한다.
/// 미래 날짜는 선택할 수 없도록 올해·이번 달·오늘까지로 각 열의 범위를 제한한다.
/// (연도 점프 등으로 값이 미래가 될 때의 최종 보정은 상태를 소유한 Reducer가 담당한다.)
public struct BZBirthDatePicker: View {

    @Binding private var year: Int
    @Binding private var month: Int
    @Binding private var day: Int

    private static let minYear = 1926

    /// 오늘(년/월/일). 미래 생년월일 선택을 막기 위한 상한 기준.
    private static var today: (year: Int, month: Int, day: Int) {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return (components.year ?? minYear, components.month ?? 1, components.day ?? 1)
    }

    public init(year: Binding<Int>, month: Binding<Int>, day: Binding<Int>) {
        self._year = year
        self._month = month
        self._day = day
    }

    /// 올해를 고른 경우 이번 달까지만 노출한다.
    private var maxMonth: Int {
        year >= Self.today.year ? Self.today.month : 12
    }

    /// 올해·이번 달을 고른 경우 오늘까지만, 그 외에는 해당 월의 실제 일수까지 노출한다.
    private var maxDay: Int {
        if year >= Self.today.year && month >= Self.today.month {
            return Self.today.day
        }
        return CalendarUtil.daysInMonth(year: year, month: month)
    }

    public var body: some View {
        HStack(spacing: 0) {
            column(label: "년") {
                BZDatePicker(selection: $year, range: Self.minYear...Self.today.year) { "\($0)" }
            }
            column(label: "월") {
                BZDatePicker(selection: $month, range: 1...maxMonth) { String(format: "%02d", $0) }
            }
            column(label: "일") {
                BZDatePicker(selection: $day, range: 1...maxDay) { String(format: "%02d", $0) }
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
