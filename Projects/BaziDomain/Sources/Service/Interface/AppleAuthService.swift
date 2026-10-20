// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 애플 SDK(AuthenticationServices) 인증 동작을 담당한다.
public protocol AppleAuthService: Sendable {
    /// 애플 로그인하여 idToken과 이름(최초 로그인 시에만 존재)을 받아온다.
    func login() async throws -> AppleCredential
}

/// 애플 로그인 자격 증명. name은 최초 로그인 시에만 내려온다.
public struct AppleCredential: Sendable, Equatable {
    public let idToken: String
    public let name: String?

    public init(idToken: String, name: String?) {
        self.idToken = idToken
        self.name = name
    }
}
