// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct APIDomain {
    private static var _baseURL: String?

    public static var baseURL: String {
        guard let url = _baseURL else {
            fatalError("APIDomain.configure(baseURL:) must be called in App.init() before any network requests.")
        }
        return url
    }

    public static func configure(baseURL: String) {
        _baseURL = baseURL
    }

    public static var authURL: String        { "\(baseURL)/v1/auth" }
    public static var userURL: String        { "\(baseURL)/v1/user" }
    public static var regionURL: String      { "\(baseURL)/v1/regions" }
    public static var recentSearchURL: String { "\(baseURL)/v1/recent-searches" }
    public static var policySearchURL: String { "\(baseURL)/v1/policies" }
    public static var homeURL: String        { "\(baseURL)/v1/home" }
}
