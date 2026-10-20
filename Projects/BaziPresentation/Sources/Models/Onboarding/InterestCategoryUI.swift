// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 관심 분야(정책 소분류) 화면용 VO. rawValue = 표시명.
public enum InterestCategoryUI: String, CaseIterable, Equatable, Sendable {
    case employmentPreparation = "취업 준비"
    case workLife = "직장 생활"
    case startupBusiness = "창업"
    case housingCostSpace = "주거"
    case educationCompetency = "교육 · 성장"
    case financeLiving = "생활비 · 금융"
    case healthWelfare = "건강 · 복지"
    case rightsProtection = "권리 보호"
    case cultureArt = "문화 · 예술"
    case participationExchange = "참여 · 활동"

    public func toDomain() -> PolicySubCategoryType {
        switch self {
        case .employmentPreparation: return .employmentPreparation
        case .workLife: return .workLife
        case .startupBusiness: return .startupBusiness
        case .housingCostSpace: return .housingCostSpace
        case .educationCompetency: return .educationCompetency
        case .financeLiving: return .financeLiving
        case .healthWelfare: return .healthWelfare
        case .rightsProtection: return .rightsProtection
        case .cultureArt: return .cultureArt
        case .participationExchange: return .participationExchange
        }
    }

    public init?(domain: PolicySubCategoryType) {
        switch domain {
        case .employmentPreparation: self = .employmentPreparation
        case .workLife: self = .workLife
        case .startupBusiness: self = .startupBusiness
        case .housingCostSpace: self = .housingCostSpace
        case .educationCompetency: self = .educationCompetency
        case .financeLiving: self = .financeLiving
        case .healthWelfare: self = .healthWelfare
        case .rightsProtection: self = .rightsProtection
        case .cultureArt: self = .cultureArt
        case .participationExchange: self = .participationExchange
        }
    }
}
