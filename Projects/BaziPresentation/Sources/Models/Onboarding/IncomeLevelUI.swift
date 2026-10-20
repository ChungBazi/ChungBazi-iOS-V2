// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 소득 분위 화면용 VO. rawValue = 표시명. (1~10분위 + "잘 모르겠어요")
public enum IncomeLevelUI: String, CaseIterable, Equatable, Sendable {
    case level1 = "1분위"
    case level2 = "2분위"
    case level3 = "3분위"
    case level4 = "4분위"
    case level5 = "5분위"
    case level6 = "6분위"
    case level7 = "7분위"
    case level8 = "8분위"
    case level9 = "9분위"
    case level10 = "10분위"
    case unknown = "잘 모르겠어요"

    public func toDomain() -> IncomeLevel {
        switch self {
        case .level1: return .level1
        case .level2: return .level2
        case .level3: return .level3
        case .level4: return .level4
        case .level5: return .level5
        case .level6: return .level6
        case .level7: return .level7
        case .level8: return .level8
        case .level9: return .level9
        case .level10: return .level10
        case .unknown: return .unknown
        }
    }

    public init?(domain: IncomeLevel) {
        switch domain {
        case .level1: self = .level1
        case .level2: self = .level2
        case .level3: self = .level3
        case .level4: self = .level4
        case .level5: self = .level5
        case .level6: self = .level6
        case .level7: self = .level7
        case .level8: self = .level8
        case .level9: self = .level9
        case .level10: self = .level10
        case .unknown: self = .unknown
        }
    }
}
