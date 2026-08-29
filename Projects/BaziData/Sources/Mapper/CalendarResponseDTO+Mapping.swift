// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziNetwork

extension CalendarResponseDTO {
    /// 서버가 내려준 마감일 문자열("yyyy-MM-dd")을 Date로 변환한다.
    /// 기기 타임존 기준으로 파싱되어(캘린더 화면의 `Calendar.current` 일 경계와 일치), 로컬 자정 시각이 된다.
    /// (서버 실제 포맷 확인 후 dateFormat 조정 — 스펙 §11)
    func toDeadlineDates() -> [Date] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return deadlineDates.compactMap { formatter.date(from: $0) }
    }
}
