// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

// @unchecked Sendable: UserDefaults는 OS 레벨에서 thread-safe가 보장된다.
public final class UserDefaultsStorage: @unchecked Sendable {
    private let defaults: UserDefaults

    private enum Key: String {
        case fcmToken
        case hasSetNickname
        case hasCompletedOnboarding
        case refreshTokenExpiryDate
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var fcmToken: String? {
        get { defaults.string(forKey: Key.fcmToken.rawValue) }
        set { defaults.set(newValue, forKey: Key.fcmToken.rawValue) }
    }

    public var hasSetNickname: Bool {
        get { defaults.bool(forKey: Key.hasSetNickname.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasSetNickname.rawValue) }
    }

    public var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding.rawValue) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding.rawValue) }
    }

    public func resetSessionState() {
        defaults.removeObject(forKey: Key.hasSetNickname.rawValue)
        defaults.removeObject(forKey: Key.hasCompletedOnboarding.rawValue)
    }

    // MARK: - Local Session Validity

    /// refreshToken 만료 시각(서버 기준 7일)을 로컬에서 추적한 결과 아직 유효한지 여부.
    /// 이 값은 UserDefaults에 저장되므로, 앱을 삭제 후 재설치하면 Keychain에 남아있는
    /// 토큰과 무관하게 `false`가 되어 재로그인을 유도한다.
    public var hasValidLocalSession: Bool {
        guard let expiryDate = refreshTokenExpiryDate else { return false }
        return Date() < expiryDate
    }

    public func markSessionValid() {
        refreshTokenExpiryDate = Date().addingTimeInterval(Self.refreshTokenLifetime)
    }

    public func invalidateSession() {
        refreshTokenExpiryDate = nil
    }

    // MARK: - Private

    private static let refreshTokenLifetime: TimeInterval = 7 * 24 * 60 * 60

    private var refreshTokenExpiryDate: Date? {
        get { defaults.object(forKey: Key.refreshTokenExpiryDate.rawValue) as? Date }
        set { defaults.set(newValue, forKey: Key.refreshTokenExpiryDate.rawValue) }
    }
}
