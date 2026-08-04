// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziStorage

public struct PushTokenRepositoryImpl: PushTokenRepository {

    private let storage: UserDefaultsStorage

    public init(storage: UserDefaultsStorage) {
        self.storage = storage
    }

    public func currentToken() async -> String? {
        storage.fcmToken
    }

    public func saveToken(_ token: String?) {
        storage.fcmToken = token
    }
}
