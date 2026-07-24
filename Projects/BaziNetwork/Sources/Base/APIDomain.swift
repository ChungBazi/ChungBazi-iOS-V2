// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct APIDomain {
    // App.init()에서 1회만 configure(baseURL:)로 쓰고 이후로는 읽기만 하는 계약이라 동시 쓰기 경합이 없음
    nonisolated(unsafe) private static var _baseURL: URL?

    public static var baseURL: URL {
        guard let url = _baseURL else {
            fatalError("APIDomain.configure(baseURL:) must be called in App.init() before any network requests.")
        }
        return url
    }

    public static func configure(baseURL: String) {
        guard let url = URL(string: baseURL) else {
            fatalError("BASE_URL이 유효한 URL 형식이 아닙니다: \(baseURL)")
        }
        _baseURL = url
    }

    public static var authURL: URL        { baseURL.appendingPathComponent("v1/auth") }
    public static var userURL: URL        { baseURL.appendingPathComponent("v1/user") }
    public static var regionURL: URL      { baseURL.appendingPathComponent("v1/regions") }
    public static var recentSearchURL: URL { baseURL.appendingPathComponent("v1/recent-searches") }
    public static var policySearchURL: URL { baseURL.appendingPathComponent("v1/policies") }
    public static var homeURL: URL        { baseURL.appendingPathComponent("v1/home") }
}
