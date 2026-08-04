// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public enum PolicySubCategoryType: String, CaseIterable, Sendable {
    case employmentPreparation = "EMPLOYMENT_PREPARATION"
    case workLife = "WORK_LIFE"
    case startupBusiness = "STARTUP_BUSINESS"
    case housingCostSpace = "HOUSING_COST_SPACE"
    case educationCompetency = "EDUCATION_COMPETENCY"
    case financeLiving = "FINANCE_LIVING"
    case healthWelfare = "HEALTH_WELFARE"
    case rightsProtection = "RIGHTS_PROTECTION"
    case cultureArt = "CULTURE_ART"
    case participationExchange = "PARTICIPATION_EXCHANGE"

    public var displayName: String {
        switch self {
        case .employmentPreparation: return "취업 준비"
        case .workLife: return "직장 생활"
        case .startupBusiness: return "창업"
        case .housingCostSpace: return "주거"
        case .educationCompetency: return "교육 · 성장"
        case .financeLiving: return "생활비 · 금융"
        case .healthWelfare: return "건강 · 복지"
        case .rightsProtection: return "권리 보호"
        case .cultureArt: return "문화 · 예술"
        case .participationExchange: return "참여 · 활동"
        }
    }
}
