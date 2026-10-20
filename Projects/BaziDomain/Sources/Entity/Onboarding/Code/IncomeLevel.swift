// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum IncomeLevel: String, CaseIterable, Sendable {
    case level1 = "LEVEL_1"
    case level2 = "LEVEL_2"
    case level3 = "LEVEL_3"
    case level4 = "LEVEL_4"
    case level5 = "LEVEL_5"
    case level6 = "LEVEL_6"
    case level7 = "LEVEL_7"
    case level8 = "LEVEL_8"
    case level9 = "LEVEL_9"
    case level10 = "LEVEL_10"
    case unknown = "UNKNOWN"

    /// 1~10분위를 먼저 보여주고 "잘 모르겠어요"를 마지막에 둔다.
    public static var onboardingOptions: [IncomeLevel] {
        [.level1, .level2, .level3, .level4, .level5, .level6, .level7, .level8, .level9, .level10, .unknown]
    }
}
