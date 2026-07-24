// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

import ComposableArchitecture

public struct MainView: View {

    // MARK: - Properties

    @Bindable var store: StoreOf<MainFeature>

    // MARK: - Init

    public init(store: StoreOf<MainFeature>) {
        self.store = store
    }

    // MARK: - Body

    public var body: some View {
        content
    }
}

// MARK: - Subviews

extension MainView {

    private var content: some View {
        TabView(selection: selectedTabBinding) {
            HomeView(store: store.scope(state: \.home, action: \.home))
                .tabItem { Label("홈", systemImage: "house") }
                .tag(MainTab.home)

            SearchView(store: store.scope(state: \.search, action: \.search))
                .tabItem { Label("검색", systemImage: "magnifyingglass") }
                .tag(MainTab.search)

            MyPolicyView(store: store.scope(state: \.myPolicy, action: \.myPolicy))
                .tabItem { Label("내 정책", systemImage: "doc.text") }
                .tag(MainTab.myPolicy)

            ProfileView(store: store.scope(state: \.profile, action: \.profile))
                .tabItem { Label("프로필", systemImage: "person") }
                .tag(MainTab.profile)
        }
    }

    private var selectedTabBinding: Binding<MainTab> {
        Binding(
            get: { store.selectedTab },
            set: { store.send(.didSelectTab($0)) }
        )
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
