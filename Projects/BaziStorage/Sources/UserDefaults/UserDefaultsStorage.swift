// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

// @unchecked Sendable: UserDefaults는 OS 레벨에서 thread-safe가 보장된다.
public final class UserDefaultsStorage: @unchecked Sendable {
    private let defaults: UserDefaults

    private enum Key: String {
        case fcmToken
        case hasSetNickname
        case hasCompletedOnboarding
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
}
