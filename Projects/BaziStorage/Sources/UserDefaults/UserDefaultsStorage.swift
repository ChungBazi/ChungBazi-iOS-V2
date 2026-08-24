// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

// @unchecked Sendable: UserDefaults는 OS 레벨에서 thread-safe가 보장된다.
public final class UserDefaultsStorage: @unchecked Sendable {
    private let defaults: UserDefaults

    private enum Key: String {
        case fcmToken
        case hasSetNickname
        case hasCompletedOnboarding
        case sessionMarker
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

    // MARK: - Session Marker

    /// 이 설치에서 로그인한 적 있는지. 로그인/재발급 시 true, 로그아웃 시 false.
    /// 재설치하면 UserDefaults가 초기화되어 false → Keychain 토큰과 무관하게 재로그인 유도.
    public var hasSessionMarker: Bool {
        defaults.bool(forKey: Key.sessionMarker.rawValue)
    }

    public func markSessionValid() {
        defaults.set(true, forKey: Key.sessionMarker.rawValue)
    }

    public func invalidateSession() {
        defaults.set(false, forKey: Key.sessionMarker.rawValue)
    }
}
