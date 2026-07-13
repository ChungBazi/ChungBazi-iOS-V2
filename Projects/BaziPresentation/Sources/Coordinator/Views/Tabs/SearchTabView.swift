// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct SearchTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.search.path) {
            Text("Search") // TODO: SearchView 구현 후 교체
                .navigationDestination(for: SearchRoute.self) { buildSearchView(for: $0) }
                .navigationDestination(for: SharedRoute.self) { SharedRouteView(route: $0) }
        }
    }

    @ViewBuilder
    private func buildSearchView(for route: SearchRoute) -> some View {
        switch route {
        case .searchResult(let query): Text("검색 결과: \(query)") // TODO
        }
    }
}
