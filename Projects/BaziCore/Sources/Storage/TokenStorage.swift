// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol TokenStorage: AnyObject, Sendable {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    /// 이 설치에서 로그인한 적 있는지(마커). 재설치 시 false → 재로그인 유도.
    /// 토큰 유효성 판정은 서버가 담당하고, 클라는 만료 시각을 추정하지 않는다.
    var hasSessionMarker: Bool { get }
    func saveTokens(accessToken: String, refreshToken: String)
    func clearTokens()
}
