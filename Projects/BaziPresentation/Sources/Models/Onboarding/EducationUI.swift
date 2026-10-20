// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 학업 단계 화면용 VO. rawValue = 표시명. (검색 전용 `noneRestrict`는 온보딩 입력에서 제외)
public enum EducationUI: String, CaseIterable, Equatable, Sendable {
    case highSchoolAttending = "고등학교에 재학 중이에요"
    case highSchoolGraduatedNotAttending = "고등학교를 졸업했어요 (검정고시 포함)"
    case universityAttendingOrOnLeave = "대학교에 재학·휴학·수료 중이에요"
    case universityGraduated = "대학교를 졸업했어요"
    case graduateSchoolAttendingOrCompleted = "석·박사 과정을 밟고 있거나 수료했어요."
    case graduateSchoolGraduated = "석·박사 학위를 취득했어요."
    case etcOrNone = "기타 / 해당 없어요"

    public func toDomain() -> EducationCode {
        switch self {
        case .highSchoolAttending: return .highSchoolAttending
        case .highSchoolGraduatedNotAttending: return .highSchoolGraduatedNotAttending
        case .universityAttendingOrOnLeave: return .universityAttendingOrOnLeave
        case .universityGraduated: return .universityGraduated
        case .graduateSchoolAttendingOrCompleted: return .graduateSchoolAttendingOrCompleted
        case .graduateSchoolGraduated: return .graduateSchoolGraduated
        case .etcOrNone: return .etcOrNone
        }
    }

    public init?(domain: EducationCode) {
        switch domain {
        case .highSchoolAttending: self = .highSchoolAttending
        case .highSchoolGraduatedNotAttending: self = .highSchoolGraduatedNotAttending
        case .universityAttendingOrOnLeave: self = .universityAttendingOrOnLeave
        case .universityGraduated: self = .universityGraduated
        case .graduateSchoolAttendingOrCompleted: self = .graduateSchoolAttendingOrCompleted
        case .graduateSchoolGraduated: self = .graduateSchoolGraduated
        case .etcOrNone: self = .etcOrNone
        case .noneRestrict: return nil
        }
    }
}
