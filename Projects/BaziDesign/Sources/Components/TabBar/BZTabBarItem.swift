// Copyright © 2026 ChungBazi. All rights reserved.

/// 하단 탭바를 구성하는 4개 탭의 타이틀/아이콘 매핑.
/// 실제 `TabView`(OS 버전 분기, 모서리 처리 등)는 앱의 MainView가 담당하고,
/// 여기서는 디자인 시스템 데이터(타이틀/선택-비선택 아이콘)만 제공한다.
public enum BZTabBarItem: CaseIterable {
    case home
    case myPolicy
    case search
    case profile

    public var title: String {
        switch self {
        case .home: return "홈"
        case .myPolicy: return "내 정책"
        case .search: return "검색"
        case .profile: return "프로필"
        }
    }

    public var selectedImage: BaziImage {
        switch self {
        case .home: return .homeSelectIcon
        case .myPolicy: return .mypolicySelectIcon
        case .search: return .searchSelectIcon
        case .profile: return .profileSelectIcon
        }
    }

    public var unselectedImage: BaziImage {
        switch self {
        case .home: return .homeUnselectIcon
        case .myPolicy: return .mypolicyUnselectIcon
        case .search: return .searchUnselectIcon
        case .profile: return .profileUnselectIcon
        }
    }
}
