// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import FirebaseMessaging

import BaziDomain
import BaziStorage

public struct PushTokenRepositoryImpl: PushTokenRepository {

    private let storage: UserDefaultsStorage

    public init(storage: UserDefaultsStorage) {
        self.storage = storage
    }

    /// 캐시된 값은 AppDelegate의 비동기 토큰 수신 콜백과 경합할 수 있어,
    /// Firebase에 현재 토큰을 직접 요청해 즉시성을 보장한다. 실패 시에만 캐시로 폴백한다.
    public func currentToken() async -> String? {
        if let token = try? await Messaging.messaging().token() {
            storage.fcmToken = token
            return token
        }
        return storage.fcmToken
    }

    public func saveToken(_ token: String?) {
        storage.fcmToken = token
    }
}
