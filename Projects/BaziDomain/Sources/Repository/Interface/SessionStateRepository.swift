// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol SessionStateRepository: Sendable {
    var hasSetNickname: Bool { get }
    var hasCompletedOnboarding: Bool { get }
    func setHasSetNickname(_ value: Bool)
    func setHasCompletedOnboarding(_ value: Bool)
    func reset()
}
