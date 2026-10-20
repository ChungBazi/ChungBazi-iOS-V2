// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 캘린더 화면(21번)의 한 달치 그리드. 지역설정과 무관하게 일요일 시작 기준으로 첫 주의 앞 칸을 nil로 패딩한다.
public struct CalendarMonth: Equatable, Identifiable, Sendable {
    public let firstDayOfMonth: Date
    public let title: String
    /// 첫 주의 앞 칸을 nil로 패딩한 일자 목록. `nil`은 해당 요일에 표시할 날짜가 없는 칸.
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

        // 헤더가 일요일~토요일 고정이므로, 지역설정(firstWeekday)과 무관하게 항상 일요일 시작으로 앞 칸을 패딩한다.
        // .weekday는 firstWeekday와 무관하게 1(일)~7(토)로 고정이라 (weekday - 1)이 곧 일요일 시작 오프셋이다.
        let leadingPadding = calendar.component(.weekday, from: monthStart) - 1

        let days: [Date?] = Array(repeating: nil, count: leadingPadding) + range.compactMap { day in
            calendar.date(byAdding: .day, value: day - 1, to: monthStart)
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월"

        return CalendarMonth(firstDayOfMonth: monthStart, title: formatter.string(from: monthStart), days: days)
    }
}

// MARK: - Mock

extension CalendarMonth {

    /// 선택된 달 기준 상·하로 생성할 개월 수(±2년). 한 번에 정적으로 생성한다.
    public static let scrollableMonthRange = 24

    // TODO: BaziDomain의 내 정책 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static func mockMonths(centeredOn date: Date, calendar: Calendar = .current) -> [CalendarMonth] {
        // 선택된 달을 중심으로 ±2년(±scrollableMonthRange개월)을 한 번에 정적으로 생성한다. (진입 시 그 달로 스크롤)
        let start = calendar.date(byAdding: .month, value: -scrollableMonthRange, to: date) ?? date
        return generate(from: start, monthCount: scrollableMonthRange * 2 + 1, calendar: calendar)
    }
}
