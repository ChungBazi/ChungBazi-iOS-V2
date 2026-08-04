// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

/// 하단 탭바를 구성하는 4개 탭.
public enum BZTabBarItem: CaseIterable, Identifiable {
    case home
    case myPolicy
    case search
    case profile

    public var id: Self { self }

    var title: String {
        switch self {
        case .home: return "홈"
        case .myPolicy: return "내 정책"
        case .search: return "검색"
        case .profile: return "프로필"
        }
    }

    var selectedImage: BaziImage {
        switch self {
        case .home: return .homeSelectIcon
        case .myPolicy: return .mypolicySelectIcon
        case .search: return .searchSelectIcon
        case .profile: return .profileSelectIcon
        }
    }

    var unselectedImage: BaziImage {
        switch self {
        case .home: return .homeUnselectIcon
        case .myPolicy: return .mypolicyUnselectIcon
        case .search: return .searchUnselectIcon
        case .profile: return .profileUnselectIcon
        }
    }
}

/// iOS 26 이상에서는 캡슐형 유리효과, iOS 18 이하에서는 평평한 바
/// OS가 자동으로 그려주는 표준 `TabView`를 감싼 하단 탭바. 배경/블러/캡슐 등은 직접 그리지 않는다.
public struct BZTabBar<Content: View>: View {

    // MARK: - Properties

    @Binding private var selection: BZTabBarItem
    private let content: (BZTabBarItem) -> Content

    // MARK: - Init

    public init(
        selection: Binding<BZTabBarItem>,
        @ViewBuilder content: @escaping (BZTabBarItem) -> Content
    ) {
        self._selection = selection
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        Group {
            if #available(iOS 18.0, *) {
                modernTabView
            } else {
                legacyTabView
            }
        }
        .tint(Color.grayBlack)
        .onAppear(perform: Self.configureTabBarAppearance)
    }

    /// iOS 18+: `Tab`사용
    @available(iOS 18.0, *)
    private var modernTabView: some View {
        TabView(selection: $selection) {
            ForEach(BZTabBarItem.allCases) { item in
                Tab(value: item) {
                    content(item)
                } label: {
                    Image.bazi(item == selection ? item.selectedImage : item.unselectedImage)
                    Text(item.title)
                }
            }
        }
    }

    /// iOS 17 이하:  `.tabItem` 사용
    private var legacyTabView: some View {
        TabView(selection: $selection) {
            ForEach(BZTabBarItem.allCases) { item in
                content(item)
                    .tabItem {
                        Image.bazi(item == selection ? item.selectedImage : item.unselectedImage)
                        Text(item.title)
                    }
                    .id(item == selection)
                    .tag(item)
            }
        }
    }

    /// 라벨 텍스트 색만 SwiftUI에 직접 지정하는 API가 없어 `UITabBarAppearance`로 설정한다.
    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.gray600)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

// MARK: - Preview

private struct BZTabBarPreview: View {
    @State private var selection: BZTabBarItem = .home

    var body: some View {
        BZTabBar(selection: $selection) { item in
            Text(item.title)
        }
    }
}

#Preview("Default") {
    BZTabBarPreview()
}

/// 캔버스에서 iOS 18+ 시뮬레이터로 바꿔서 확인
#Preview("iOS 18+") {
    BZTabBarPreview()
}
