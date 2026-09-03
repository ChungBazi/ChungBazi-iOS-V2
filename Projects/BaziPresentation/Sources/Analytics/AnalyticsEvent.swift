// Copyright © 2026 ChungBazi. All rights reserved.

/// Amplitude로 전송할 타입드 분석 이벤트. `name`/`properties`로 매핑한다.
/// (단계별로 case를 추가한다 — Phase A: 화면/계정 생명주기)
public enum AnalyticsEvent: Equatable, Sendable {
    case screenView(ScreenName)
    case login(method: String, isNewUser: Bool)
    case logout
    case withdrawComplete(reasons: [String])

    /// Amplitude 이벤트명(snake_case).
    public var name: String {
        switch self {
        case .screenView: return "screen_view"
        case .login: return "login"
        case .logout: return "logout"
        case .withdrawComplete: return "withdraw_complete"
        }
    }

    /// Amplitude 이벤트 파라미터.
    public var properties: [String: Any] {
        switch self {
        case let .screenView(screen):
            return ["screen_name": screen.rawValue]
        case let .login(method, isNewUser):
            return ["method": method, "is_new_user": isNewUser]
        case .logout:
            return [:]
        case let .withdrawComplete(reasons):
            return ["reasons": reasons]
        }
    }
}

/// `screen_view`의 화면 식별자. (단계별로 추가)
public enum ScreenName: String, Sendable {
    case home
    case search
    case myPolicy = "my_policy"
    case profile
}
