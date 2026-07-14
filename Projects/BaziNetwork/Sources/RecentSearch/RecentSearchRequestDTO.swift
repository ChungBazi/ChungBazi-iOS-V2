// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct UpdateAutoSaveRequestDTO: Encodable {
    public let enabled: Bool

    public init(enabled: Bool) {
        self.enabled = enabled
    }
}
