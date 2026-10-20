// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziStorage

public struct SessionStateRepositoryImpl: SessionStateRepository {

    private let storage: UserDefaultsStorage

    public init(storage: UserDefaultsStorage) {
        self.storage = storage
    }

    public var hasSetNickname: Bool { storage.hasSetNickname }
    public var hasCompletedOnboarding: Bool { storage.hasCompletedOnboarding }
    public var userName: String? { storage.userName }
    public var socialType: SocialType? { storage.socialType.flatMap(SocialType.init(rawValue:)) }

    public func setHasSetNickname(_ value: Bool) {
        storage.hasSetNickname = value
    }

    public func setHasCompletedOnboarding(_ value: Bool) {
        storage.hasCompletedOnboarding = value
    }

    public func setUserName(_ value: String) {
        storage.userName = value
    }

    public func setSocialType(_ value: SocialType) {
        storage.socialType = value.rawValue
    }

    public func reset() {
        storage.resetSessionState()
    }
}
