// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign

/// 정책 분야. 홈 "분야별 정책" 아이콘 목록과 분야 필터에서 공유한다.
public enum PolicyCategoryUI: String, CaseIterable, Equatable, Identifiable, Sendable {
    case job = "취업·창업"
    case dwelling = "월세·주거"
    case study = "공부·성장"
    case livingSupport = "생활지원"
    case activity = "활동·경험"

    public var id: String { rawValue }

    public var icon: BaziImage {
        switch self {
        case .job: return .jobIcon
        case .dwelling: return .dwellingIcon
        case .study: return .studyIcon
        case .livingSupport: return .livingSupportIcon
        case .activity: return .activityIcon
        }
    }

    /// Large, Flip 카드 썸네일용 분야별 이미지.
    public var cardImage: BaziImage {
        switch self {
        case .job: return .jobCard
        case .dwelling: return .housingCard
        case .study: return .growthCard
        case .livingSupport: return .lifesupportCard
        case .activity: return .activityCard
        }
    }
}
