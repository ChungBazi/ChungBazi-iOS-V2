// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 로그인 요청에 실어 보낼 FCM 토큰을 조회/저장한다.
public protocol PushTokenRepository: Sendable {
    func currentToken() async -> String?
    func saveToken(_ token: String?)
}
