// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct RegionEntity: Equatable, Sendable, Identifiable {
    public var id: String { code }
    public let code: String
    public let name: String

    public init(code: String, name: String) {
        self.code = code
        self.name = name
    }
}
