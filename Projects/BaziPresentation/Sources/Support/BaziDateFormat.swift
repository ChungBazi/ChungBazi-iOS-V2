// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 앱 전역 날짜 포맷을 한곳에서 관리한다.
/// DateFormatter는 생성 비용이 커서 포맷별 `static let`으로 1회만 만들어 재사용한다.
///
/// - 로컬 Date 표시(달·요일 등)는 기기 시간대 그대로(ko_KR, timeZone 미지정).
/// - 서버 날짜("yyyy-MM-dd" 같은 시각 없는 날짜)는 Asia/Seoul로 고정해 파싱·표시가 일관되게 라운드트립되도록 한다.
enum BaziDateFormat {

    // MARK: - Display (로컬 Date 표시용, ko_KR)

    /// "yyyy년 M월"
    static let yearMonth = displayFormatter("yyyy년 M월")
    /// "M월 d일 (E)"
    static let monthDayWeekday = displayFormatter("M월 d일 (E)")
    /// "E" (요일)
    static let weekday = displayFormatter("E")

    // MARK: - Server date (yyyy-MM-dd, Asia/Seoul)

    /// 서버 날짜 문자열("yyyy-MM-dd") 파싱용.
    static let serverDay = serverFormatter("yyyy-MM-dd")
    /// 서버 날짜를 사용자에게 보여줄 때: "yyyy년 MM월 dd일".
    static let koreanDay = koreanServerFormatter("yyyy년 MM월 dd일")

    // MARK: - Server param 문자열 빌더

    /// (연·월·일) → "yyyy-MM-dd".
    static func serverDayString(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d-%02d-%02d", year, month, day)
    }

    /// 주어진 calendar 기준 Date → "yyyy-MM-dd".
    static func serverDayString(_ date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return serverDayString(year: components.year ?? 0, month: components.month ?? 0, day: components.day ?? 0)
    }

    /// (연·월) → "yyyy-MM".
    static func serverMonthString(year: Int, month: Int) -> String {
        String(format: "%04d-%02d", year, month)
    }

    /// 주어진 calendar 기준 Date → "yyyy-MM".
    static func serverMonthString(_ date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month], from: date)
        return serverMonthString(year: components.year ?? 0, month: components.month ?? 0)
    }

    // MARK: - Factories

    private static func displayFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = format
        return formatter
    }

    private static func serverFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = format
        return formatter
    }

    private static func koreanServerFormatter(_ format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        formatter.dateFormat = format
        return formatter
    }
}
