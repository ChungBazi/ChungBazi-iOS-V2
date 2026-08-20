// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 캘린더 화면(21번)의 한 달치 그리드. 일요일 시작 6주 그리드로 패딩한다.
public struct CalendarMonth: Equatable, Identifiable, Sendable {
    public let firstDayOfMonth: Date
    public let title: String
    /// 앞뒤 패딩을 포함한 일자 목록. `nil`은 해당 요일에 표시할 날짜가 없는 칸.
    public let days: [Date?]

    public var id: Date { firstDayOfMonth }

    public init(firstDayOfMonth: Date, title: String, days: [Date?]) {
        self.firstDayOfMonth = firstDayOfMonth
        self.title = title
        self.days = days
    }
}

// MARK: - Generation

extension CalendarMonth {

    /// `monthCount`개월치를 `startDate`가 속한 달부터 생성한다.
    public static func generate(from startDate: Date, monthCount: Int, calendar: Calendar = .current) -> [CalendarMonth] {
        guard let firstMonthStart = calendar.date(
            from: calendar.dateComponents([.year, .month], from: startDate)
        ) else { return [] }

        return (0..<monthCount).compactMap { offset in
            guard let monthStart = calendar.date(byAdding: .month, value: offset, to: firstMonthStart) else { return nil }
            return month(containing: monthStart, calendar: calendar)
        }
    }

    private static func month(containing monthStart: Date, calendar: Calendar) -> CalendarMonth? {
        guard let range = calendar.range(of: .day, in: .month, for: monthStart) else { return nil }

        let leadingWeekday = calendar.component(.weekday, from: monthStart) - calendar.firstWeekday
        let leadingPadding = (leadingWeekday + 7) % 7

        let days: [Date?] = Array(repeating: nil, count: leadingPadding) + range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"

        return CalendarMonth(firstDayOfMonth: monthStart, title: formatter.string(from: monthStart), days: days)
    }

    /// 기존 첫 달 바로 앞으로 이어지는 `monthCount`개월치를 생성한다. (위쪽 무한스크롤용)
    public static func generate(before firstMonth: Date, monthCount: Int, calendar: Calendar = .current) -> [CalendarMonth] {
        guard let start = calendar.date(byAdding: .month, value: -monthCount, to: firstMonth) else { return [] }
        return generate(from: start, monthCount: monthCount, calendar: calendar)
    }

    /// 기존 마지막 달 바로 다음부터 이어지는 `monthCount`개월치를 생성한다. (아래쪽 무한스크롤용)
    public static func generate(after lastMonth: Date, monthCount: Int, calendar: Calendar = .current) -> [CalendarMonth] {
        guard let start = calendar.date(byAdding: .month, value: 1, to: lastMonth) else { return [] }
        return generate(from: start, monthCount: monthCount, calendar: calendar)
    }

    /// 위쪽 무한스크롤용이되, `lowerBound`보다 이른 달은 잘라낸다.
    public static func generate(
        before firstMonth: Date,
        monthCount: Int,
        notBefore lowerBound: Date,
        calendar: Calendar = .current
    ) -> [CalendarMonth] {
        generate(before: firstMonth, monthCount: monthCount, calendar: calendar)
            .filter { $0.firstDayOfMonth >= lowerBound }
    }

    /// 아래쪽 무한스크롤용이되, `upperBound`보다 늦은 달은 잘라낸다.
    public static func generate(
        after lastMonth: Date,
        monthCount: Int,
        notAfter upperBound: Date,
        calendar: Calendar = .current
    ) -> [CalendarMonth] {
        generate(after: lastMonth, monthCount: monthCount, calendar: calendar)
            .filter { $0.firstDayOfMonth <= upperBound }
    }
}

// MARK: - Mock

extension CalendarMonth {

    /// 상하 무한스크롤 여유를 두기 위해 선택된 달 기준 앞뒤로 생성한다.
    public static let pageSize = 6

    /// 무한스크롤 가능 범위(상/하 각 24개월)의 개월 수.
    public static let scrollableMonthRange = 24

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static func mockMonths(centeredOn date: Date, calendar: Calendar = .current) -> [CalendarMonth] {
        generate(from: date, monthCount: pageSize * 2, calendar: calendar)
    }
}
