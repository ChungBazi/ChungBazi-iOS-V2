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
}
