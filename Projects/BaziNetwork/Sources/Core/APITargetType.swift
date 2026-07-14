// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation
import Moya

public protocol APITargetType: TargetType {}

extension APITargetType {
    public var baseURL: URL { URL(string: APIDomain.baseURL)! }
    public var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
