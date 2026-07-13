// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

public struct AppCoordinatorContainer: View {
    @State private var coordinator = AppCoordinator()

    public init() {}

    public var body: some View {
        contentView
            .environment(coordinator)
            .sheet(item: $coordinator.presentedSheet) { modal in
                buildModalView(for: modal)
                    .environment(coordinator)
            }
            .fullScreenCover(item: $coordinator.presentedFullScreen) { modal in
                buildModalView(for: modal)
                    .environment(coordinator)
            }
    }

    @ViewBuilder
    private var contentView: some View {
        switch coordinator.appPhase {
        case .splash:
            Text("Splash") // TODO: SplashView 구현 후 교체
        case .auth(let root):
            AuthCoordinatorView(root: root)
        case .main:
            MainCoordinatorView()
        }
    }

    @ViewBuilder
    private func buildModalView(for route: ModalRoute) -> some View {
        switch route {
        case .webView(let url):
            Text("WebView: \(url.absoluteString)") // TODO
        case .calendarPolicyList(let date):
            Text("CalendarPolicyList: \(date.description)") // TODO
        }
    }
}
