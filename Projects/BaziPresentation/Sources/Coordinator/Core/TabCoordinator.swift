// Copyright © 2026 ChungBazi. All rights reserved.

import SwiftUI

@MainActor
@Observable
public final class TabCoordinator {
    public var path = NavigationPath()

    public init() {}

    public func push<R: Hashable>(_ route: R) { path.append(route) }
    public func pop() {
        guard !path.isEmpty else { return }; path.removeLast()
    }
    public func popToRoot() { path = NavigationPath() }
}
