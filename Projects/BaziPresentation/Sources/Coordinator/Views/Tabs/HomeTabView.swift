// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct HomeTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.home.path) {
            Text("Home") // TODO: HomeView 구현 후 교체
                .navigationDestination(for: HomeRoute.self) { buildHomeView(for: $0) }
                .navigationDestination(for: SharedRoute.self) { SharedRouteView(route: $0) }
        }
    }

    @ViewBuilder
    private func buildHomeView(for route: HomeRoute) -> some View {
        switch route {
        case .customPolicyList:             Text("맞춤정책 더보기")       // TODO
        case .categoryPolicyList(let cat):  Text("분야별: \(cat)")        // TODO
        case .popularPolicyList:            Text("인기정책 더보기")        // TODO
        case .deadlinePolicyList:           Text("마감임박 더보기")        // TODO
        case .newPolicyList:                Text("새로 뜬 정책 더보기")    // TODO
        case .attendanceCalendar:           Text("출석 달력")              // TODO
        case .notification:                 Text("알림")                   // TODO
        }
    }
}
