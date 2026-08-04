// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public protocol TokenStorage: AnyObject, Sendable {
    var accessToken: String? { get }
    var refreshToken: String? { get }
    /// refreshToken 만료 시각(서버 기준 7일)을 로컬에서 추적한 결과 아직 유효한지 여부.
    /// 만료 시각은 UserDefaults에 저장되므로, 앱을 삭제 후 재설치 및 만료시간이 지나면
    /// Keychain에 남아있는 토큰과 무관하게 이 값은 `false`가 되어 재로그인을 유도한다.
    var hasValidLocalSession: Bool { get }
    func saveTokens(accessToken: String, refreshToken: String)
    func clearTokens()
}
