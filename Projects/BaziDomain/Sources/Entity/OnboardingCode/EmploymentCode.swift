// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum EmploymentCode: String, CaseIterable, Sendable {
    case employed = "EMPLOYED"
    case temporaryDailyWorker = "TEMPORARY_DAILY_WORKER"
    case selfEmployed = "SELF_EMPLOYED"
    case freelancer = "FREELANCER"
    case unemployed = "UNEMPLOYED"
    case etcOrNone = "ETC_OR_NONE"
    /// 검색 필터 전용 값. 온보딩 입력 옵션에서는 제외한다.
    case noneRestrict = "NONE_RESTRICT"

    public static var onboardingOptions: [EmploymentCode] {
        allCases.filter { $0 != .noneRestrict }
    }

    public var displayName: String {
        switch self {
        case .employed: return "재직 중이에요 (정규직/계약직 포함)"
        case .temporaryDailyWorker: return "단기·일용 근로 중이에요"
        case .selfEmployed: return "자영업/사업을 하고 있어요"
        case .freelancer: return "프리랜서로 일하고 있어요"
        case .unemployed: return "현재 일하고 있지 않아요"
        case .etcOrNone: return "기타 / 해당 없어요"
        case .noneRestrict: return "제한 없음"
        }
    }
}
