// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign

/// 정책 분야. 검색 필터, 정책 카드 태그 등 여러 화면이 공유한다.
public enum PolicyCategory: String, CaseIterable, Equatable, Identifiable, Sendable {
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
}
