// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

struct MyPolicyTabView: View {
    @Environment(AppCoordinator.self) private var coordinator

    var body: some View {
        @Bindable var coordinator = coordinator
        NavigationStack(path: $coordinator.myPolicy.path) {
            Text("MyPolicy") // TODO: MyPolicyView 구현 후 교체
                .navigationDestination(for: MyPolicyRoute.self) { buildMyPolicyView(for: $0) }
                .navigationDestination(for: SharedRoute.self) { SharedRouteView(route: $0) }
        }
    }

    @ViewBuilder
    private func buildMyPolicyView(for route: MyPolicyRoute) -> some View {
        switch route {
        case .policyList:                  Text("내정책 전체보기")      // TODO
        case .calendar:                    Text("캘린더")               // TODO
        case .policyMemo(let policyId):    Text("메모: \(policyId)")    // TODO
        }
    }
}
