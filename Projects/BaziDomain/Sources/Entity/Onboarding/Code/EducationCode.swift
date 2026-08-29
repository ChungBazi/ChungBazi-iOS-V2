// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum EducationCode: String, CaseIterable, Sendable {
    case highSchoolAttending = "HIGH_SCHOOL_ATTENDING"
    case highSchoolGraduatedNotAttending = "HIGH_SCHOOL_GRADUATED_NOT_ATTENDING"
    case universityAttendingOrOnLeave = "UNIVERSITY_ATTENDING_OR_ON_LEAVE"
    case universityGraduated = "UNIVERSITY_GRADUATED"
    case graduateSchoolAttendingOrCompleted = "GRADUATE_SCHOOL_ATTENDING_OR_COMPLETED"
    case graduateSchoolGraduated = "GRADUATE_SCHOOL_GRADUATED"
    case etcOrNone = "ETC_OR_NONE"
    /// 검색 필터 전용 값. 온보딩 입력 옵션에서는 제외한다.
    case noneRestrict = "NONE_RESTRICT"

    public static var onboardingOptions: [EducationCode] {
        allCases.filter { $0 != .noneRestrict }
    }
}
