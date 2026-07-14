// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol TokenStorage: AnyObject, Sendable {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    func saveTokens(accessToken: String, refreshToken: String)
    func clearTokens()
}
