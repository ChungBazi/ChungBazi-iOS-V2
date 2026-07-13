// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct MainCoordinatorView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        TabView(selection: $coordinator.selectedTab) {
            HomeTabView()
                .tabItem { Label("홈", systemImage: "house") }
                .tag(MainTab.home)

            SearchTabView()
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(MainTab.search)

            MyPolicyTabView()
                .tabItem { Label("내 정책", systemImage: "doc.text") }
                .tag(MainTab.myPolicy)

            ProfileTabView()
                .tabItem { Label("프로필", systemImage: "person") }
                .tag(MainTab.profile)
        }
    }
}
