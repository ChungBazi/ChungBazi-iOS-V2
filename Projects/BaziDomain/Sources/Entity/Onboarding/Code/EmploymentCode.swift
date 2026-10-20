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
}
