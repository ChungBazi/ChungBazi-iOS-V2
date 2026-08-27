// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziStorage

public struct AppPreferenceRepositoryImpl: AppPreferenceRepository {

    private let storage: UserDefaultsStorage

    public init(storage: UserDefaultsStorage) {
        self.storage = storage
    }

    public var hasSeenCustomPolicyGuide: Bool {
        storage.hasSeenCustomPolicyGuide
    }

    public func markCustomPolicyGuideSeen() {
        storage.hasSeenCustomPolicyGuide = true
    }
}
