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

    public var displayName: String {
        switch self {
        case .highSchoolAttending: return "고등학교에 재학 중이에요"
        case .highSchoolGraduatedNotAttending: return "고등학교를 졸업했어요 (검정고시 포함)"
        case .universityAttendingOrOnLeave: return "대학교에 재학·휴학·수료 중이에요"
        case .universityGraduated: return "대학교를 졸업했어요"
        case .graduateSchoolAttendingOrCompleted: return "석·박사 과정을 밟고 있거나 수료했어요."
        case .graduateSchoolGraduated: return "석·박사 학위를 취득했어요."
        case .etcOrNone: return "기타 / 해당 없어요"
        case .noneRestrict: return "제한 없음"
        }
    }
}
