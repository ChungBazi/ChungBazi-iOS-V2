// Copyright © 2026 ChungBazi. All rights reserved.

import BaziCore
import Foundation

/// 같은 앱에서 API 서버 호스트가 바뀌면 저장된 세션을 폐기한다.
public struct SessionHostGuard {
    private let tokenStorage: TokenStorage
    private let userDefaultsStorage: UserDefaultsStorage

    public init(tokenStorage: TokenStorage, userDefaultsStorage: UserDefaultsStorage = UserDefaultsStorage()) {
        self.tokenStorage = tokenStorage
        self.userDefaultsStorage = userDefaultsStorage
    }

    public func bind(to host: String) {
        // 기록이 없는 기존 설치는 세션을 유지한 채 현재 호스트만 기록한다.
        if let storedHost = userDefaultsStorage.sessionHost, storedHost != host {
            tokenStorage.clearTokens()
            userDefaultsStorage.resetSessionState()
        }
        userDefaultsStorage.sessionHost = host
    }
}
