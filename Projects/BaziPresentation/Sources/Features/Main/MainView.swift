// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI
import UIKit

import BaziDesign
import ComposableArchitecture

public struct MainView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<MainFeature>

    // MARK: - Init

    public init(store: StoreOf<MainFeature>) {
        self.store = store
        // UIAppearance 프록시는 tab bar가 window에 붙은 뒤(onAppear)에 설정하면
        // 이미 만들어진 인스턴스에 반영되지 않을 수 있어, init 시점에 실행한다.
        Self.configureAppearanceOnce
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
        .onAppear {
            // 실제 UITabBar 인스턴스를 찾아야 해서 window에 붙은 뒤인 onAppear에서 실행하되,
            // 참조 시점에 단 한 번만 평가되는 static let으로 재실행을 막는다.
            Self.configureLegacyLayoutOnce
        }
    }
}

// MARK: - TabView

extension MainView {

    @available(iOS 18.0, *)
    private var modernTabView: some View {
        TabView(selection: selectedTabBinding) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                Tab(value: tab) {
                    tabContent(for: tab)
                } label: {
                    tabLabel(for: tab)
                }
            }
        }
    }

    private var legacyTabView: some View {
        TabView(selection: selectedTabBinding) {
            ForEach(MainTab.allCases, id: \.self) { tab in
                tabContent(for: tab)
                    .tabItem { tabLabel(for: tab) }
                    .tag(tab)
            }
        }
    }

    @ViewBuilder
    private func tabContent(for tab: MainTab) -> some View {
        switch tab {
        case .home:
            HomeView(store: store.scope(state: \.home, action: \.home))
        case .search:
            SearchView(store: store.scope(state: \.search, action: \.search))
        case .myPolicy:
            MyPolicyView(store: store.scope(state: \.myPolicy, action: \.myPolicy))
        case .profile:
            ProfileView(store: store.scope(state: \.profile, action: \.profile))
        }
    }

    private func tabLabel(for tab: MainTab) -> some View {
        let isSelected = tab == store.selectedTab
        return Group {
            Image.bazi(isSelected ? tab.item.selectedImage : tab.item.unselectedImage)
            Text(tab.item.title)
        }
    }

    private var selectedTabBinding: Binding<MainTab> {
        Binding(
            get: { store.selectedTab },
            set: { store.send(.didSelectTab($0)) }
        )
    }
}

// MARK: - Tab Bar Appearance

extension MainView {

    private static let configureAppearanceOnce: Void = configureTabBarAppearance()
    private static let configureLegacyLayoutOnce: Void = configureLegacyTabBarLayoutIfNeeded()

    private static func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.bazi(.bgWhite))
        appearance.shadowColor = .clear
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(Color.gray600)]
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    private static func configureLegacyTabBarLayoutIfNeeded() {
        if #available(iOS 26.0, *) { return }

        DispatchQueue.main.async {
            guard
                let window = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .flatMap(\.windows)
                    .first(where: \.isKeyWindow),
                let tabBar = findTabBar(in: window)
            else { return }

            tabBar.layer.cornerRadius = 16
            tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            tabBar.clipsToBounds = true
        }
    }

    private static func findTabBar(in view: UIView) -> UITabBar? {
        if let tabBar = view as? UITabBar {
            return tabBar
        }
        for subview in view.subviews {
            if let found = findTabBar(in: subview) {
                return found
            }
        }
        return nil
    }
}

// MARK: - Preview

#Preview {
    MainView(
        store: Store(initialState: .init()) {
            MainFeature()
        }
    )
}
