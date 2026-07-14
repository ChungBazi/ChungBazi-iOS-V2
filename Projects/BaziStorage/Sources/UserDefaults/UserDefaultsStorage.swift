// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public final class UserDefaultsStorage {
    private let defaults: UserDefaults

    private enum Key: String {
        case fcmToken = "com.yeonho.chungbazi.fcmToken"
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var fcmToken: String? {
        get { defaults.string(forKey: Key.fcmToken.rawValue) }
        set { defaults.set(newValue, forKey: Key.fcmToken.rawValue) }
    }
}
