// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziNetwork

extension CalendarResponseDTO {
    /// 서버가 내려준 마감일 문자열("yyyy-MM-dd")을 타임존 없는 달력 날짜(연·월·일)로 변환한다.
    /// `Date`(절대시각)로 바꾸지 않으므로 파싱/표시 타임존이 달라도 어긋나지 않는다.
    /// 형식이 맞지 않는 값(3개의 숫자 파트가 아님)은 건너뛴다.
    func toDeadlineDayComponents() -> [DateComponents] {
        deadlineDates.compactMap { raw in
            let parts = raw.split(separator: "-")
            guard parts.count == 3,
                  let year = Int(parts[0]),
                  let month = Int(parts[1]),
                  let day = Int(parts[2])
            else { return nil }
            return DateComponents(year: year, month: month, day: day)
        }
    }
}
