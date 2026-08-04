// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDesign

public enum MainTab: CaseIterable {
    case home
    case myPolicy
    case search
    case profile

    var item: BZTabBarItem {
        switch self {
        case .home: return .home
        case .myPolicy: return .myPolicy
        case .search: return .search
        case .profile: return .profile
        }
    }
}
