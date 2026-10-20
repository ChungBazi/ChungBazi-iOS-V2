// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 해당 사항(여성/기초생활수급자 등). rawValue = 서버 코드값.
public enum SpecialEligibility: String, CaseIterable, Sendable {
    case woman = "WOMAN"
    case basicLivelihoodRecipient = "BASIC_LIVELIHOOD_RECIPIENT"
    case personWithDisability = "PERSON_WITH_DISABILITY"
    case militaryPersonnel = "MILITARY_PERSONNEL"
    case localTalent = "LOCAL_TALENT"
    case farmer = "FARMER"
    case singleParentFamily = "SINGLE_PARENT_FAMILY"
    case smeEmployee = "SME_EMPLOYEE"
    case notApplicable = "NONE"
}
