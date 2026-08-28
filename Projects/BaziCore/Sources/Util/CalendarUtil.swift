// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum CalendarUtil {

    /// 주어진 연/월의 실제 일수(윤년 2월 포함). 계산 불가 시 31로 대체한다.
    public static func daysInMonth(year: Int, month: Int) -> Int {
        var components = DateComponents()
        components.year = year
        components.month = month
        let calendar = Calendar(identifier: .gregorian)
        guard
            let date = calendar.date(from: components),
            let range = calendar.range(of: .day, in: .month, for: date)
        else {
            return 31
        }
        return range.count
    }

    /// 주어진 연/월/일을 오늘(`now`·`calendar` 기준)을 넘지 않도록 보정한 `(년, 월, 일)`을 돌려준다.
    /// 생년월일처럼 미래 날짜가 허용되지 않는 값의 클램핑에 사용한다.
    public static func clampToNotFuture(
        year: Int,
        month: Int,
        day: Int,
        now: Date,
        calendar: Calendar
    ) -> (year: Int, month: Int, day: Int) {
        let today = calendar.dateComponents([.year, .month, .day], from: now)
        guard let currentYear = today.year, let currentMonth = today.month, let currentDay = today.day else {
            let clampedDay = min(max(day, 1), daysInMonth(year: year, month: month))
            return (year, min(max(month, 1), 12), clampedDay)
        }

        let clampedYear = min(year, currentYear)
        var clampedMonth = min(max(month, 1), 12)
        if clampedYear == currentYear {
            clampedMonth = min(clampedMonth, currentMonth)
        }
        let upperDay = (clampedYear == currentYear && clampedMonth == currentMonth)
            ? currentDay
            : daysInMonth(year: clampedYear, month: clampedMonth)
        let clampedDay = min(max(day, 1), upperDay)

        return (clampedYear, clampedMonth, clampedDay)
    }
}
