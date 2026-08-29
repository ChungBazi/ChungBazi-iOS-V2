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
        case userName
        case socialType
        case customPolicyGuideSeen
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

    /// 서버에서 받은 사용자 닉네임. 로그인~로그아웃/탈퇴 동안 재사용한다.
    public var userName: String? {
        get { defaults.string(forKey: Key.userName.rawValue) }
        set { defaults.set(newValue, forKey: Key.userName.rawValue) }
    }

    /// 로그인한 소셜 제공자(원시값). 탈퇴 시 카카오 계정만 연결 해제하기 위해 사용한다.
    public var socialType: String? {
        get { defaults.string(forKey: Key.socialType.rawValue) }
        set { defaults.set(newValue, forKey: Key.socialType.rawValue) }
    }

    /// 맞춤정책 가이드 오버레이를 본 적 있는지. 세션과 무관하게 앱 삭제 전까지 유지된다(resetSessionState에서 지우지 않음).
    public var hasSeenCustomPolicyGuide: Bool {
        get { defaults.bool(forKey: Key.customPolicyGuideSeen.rawValue) }
        set { defaults.set(newValue, forKey: Key.customPolicyGuideSeen.rawValue) }
    }

    public func resetSessionState() {
        defaults.removeObject(forKey: Key.hasSetNickname.rawValue)
        defaults.removeObject(forKey: Key.hasCompletedOnboarding.rawValue)
        defaults.removeObject(forKey: Key.userName.rawValue)
        defaults.removeObject(forKey: Key.socialType.rawValue)
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
