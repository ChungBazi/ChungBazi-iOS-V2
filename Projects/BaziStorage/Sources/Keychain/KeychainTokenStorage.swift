// Copyright © 2026 ChungBazi. All rights reserved.

import BaziCore
import Foundation
import Security

// @unchecked Sendable: SecItem API는 OS 레벨에서 직렬화하므로 thread-safe 보장
public final class KeychainTokenStorage: TokenStorage, @unchecked Sendable {
    private let service: String
    private let userDefaultsStorage: UserDefaultsStorage

    private enum Key: String {
        case accessToken  = "com.yeonho.chungbazi.accessToken"
        case refreshToken = "com.yeonho.chungbazi.refreshToken"
    }

    public init(service: String = "com.yeonho.chungbazi", userDefaultsStorage: UserDefaultsStorage = UserDefaultsStorage()) {
        self.service = service
        self.userDefaultsStorage = userDefaultsStorage
    }

    public var accessToken: String? { read(key: .accessToken) }
    public var refreshToken: String? { read(key: .refreshToken) }

    public var hasValidLocalSession: Bool { userDefaultsStorage.hasValidLocalSession }

    public func saveTokens(accessToken: String, refreshToken: String) {
        let accessTokenSaved = save(key: .accessToken, value: accessToken)
        let refreshTokenSaved = save(key: .refreshToken, value: refreshToken)
        // 둘 중 하나라도 Keychain 저장에 실패하면 세션을 유효화하지 않는다 —
        // 그렇지 않으면 accessToken은 있지만 refreshToken이 없는 상태에서
        // hasValidLocalSession만 true가 되어, 이후 재발급 시점에 조용히 깨진다.
        guard accessTokenSaved, refreshTokenSaved else { return }
        userDefaultsStorage.markSessionValid()
    }

    public func clearTokens() {
        delete(key: .accessToken)
        delete(key: .refreshToken)
        userDefaultsStorage.invalidateSession()
    }

    // MARK: - Private, Keychain CRUD Low-level 메서드
    private func save(key: Key, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // 기존에 값이 있는지 확인하기 위한 쿼리
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        // 기존에 값이 있다면 업데이트, 없다면 추가
        let updateStatus = SecItemUpdate(query as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if updateStatus == errSecSuccess {
            return true
        }
        guard updateStatus == errSecItemNotFound else { return false }

        var newItem = query
        newItem[kSecValueData as String] = data
        // 첫 잠금 해제 후부터 재부팅 전까지 백그라운드에서도 접근 가능
        newItem[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        return SecItemAdd(newItem as CFDictionary, nil) == errSecSuccess
    }

    private func read(key: Key) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: Key) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]
        SecItemDelete(query as CFDictionary)
    }
}
