// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 해당 사항 화면용 VO. rawValue = 표시명. 선언 순서 = 그리드 표시 순서.
public enum SpecialEligibilityUI: String, CaseIterable, Equatable, Sendable {
    case woman = "여성"
    case basicLivelihoodRecipient = "기초생활수급자"
    case personWithDisability = "장애인"
    case militaryPersonnel = "군인"
    case localTalent = "지역 인재"
    case farmer = "농업인"
    case singleParentFamily = "한부모가정"
    case smeEmployee = "중소기업 재직"
    case notApplicable = "해당 없어요"

    public func toDomain() -> SpecialEligibility {
        switch self {
        case .woman: return .woman
        case .basicLivelihoodRecipient: return .basicLivelihoodRecipient
        case .personWithDisability: return .personWithDisability
        case .militaryPersonnel: return .militaryPersonnel
        case .localTalent: return .localTalent
        case .farmer: return .farmer
        case .singleParentFamily: return .singleParentFamily
        case .smeEmployee: return .smeEmployee
        case .notApplicable: return .notApplicable
        }
    }

    public init?(domain: SpecialEligibility) {
        switch domain {
        case .woman: self = .woman
        case .basicLivelihoodRecipient: self = .basicLivelihoodRecipient
        case .personWithDisability: self = .personWithDisability
        case .militaryPersonnel: self = .militaryPersonnel
        case .localTalent: self = .localTalent
        case .farmer: self = .farmer
        case .singleParentFamily: self = .singleParentFamily
        case .smeEmployee: self = .smeEmployee
        case .notApplicable: self = .notApplicable
        }
    }
}
