// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 직업 형태 화면용 VO. rawValue = 표시명. (검색 전용 `noneRestrict`는 온보딩 입력에서 제외)
public enum EmploymentUI: String, CaseIterable, Equatable, Sendable {
    case employed = "재직 중이에요 (정규직/계약직 포함)"
    case temporaryDailyWorker = "단기·일용 근로 중이에요"
    case selfEmployed = "자영업/사업을 하고 있어요"
    case freelancer = "프리랜서로 일하고 있어요"
    case unemployed = "현재 일하고 있지 않아요"
    case etcOrNone = "기타 / 해당 없어요"

    public func toDomain() -> EmploymentCode {
        switch self {
        case .employed: return .employed
        case .temporaryDailyWorker: return .temporaryDailyWorker
        case .selfEmployed: return .selfEmployed
        case .freelancer: return .freelancer
        case .unemployed: return .unemployed
        case .etcOrNone: return .etcOrNone
        }
    }

    public init?(domain: EmploymentCode) {
        switch domain {
        case .employed: self = .employed
        case .temporaryDailyWorker: self = .temporaryDailyWorker
        case .selfEmployed: self = .selfEmployed
        case .freelancer: self = .freelancer
        case .unemployed: self = .unemployed
        case .etcOrNone: self = .etcOrNone
        case .noneRestrict: return nil
        }
    }
}
