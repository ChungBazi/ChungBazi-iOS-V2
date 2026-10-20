// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

extension DateComponents {
    /// 연·월·일만으로 만든 yyyymmdd 정수 키. 타임존/절대시각 없이 "달력상 같은 날"인지 비교하는 데 쓴다.
    var yyyymmddKey: Int? {
        guard let year, let month, let day else { return nil }
        return year * 10_000 + month * 100 + day
    }
}
