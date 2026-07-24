// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct ReissueRequestDTO: Encodable {
    public let refreshToken: String
    
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
    }
}

public struct KakaoLoginRequestDTO: Encodable {
    public let accessToken: String
    public let fcmToken: String

    public init(accessToken: String, fcmToken: String) {
        self.accessToken = accessToken
        self.fcmToken = fcmToken
    }
}

public struct AppleLoginRequestDTO: Encodable {
    public let idToken: String
    public let name: String
    public let fcmToken: String
    
    public init(idToken: String, name: String, fcmToken: String) {
        self.idToken = idToken
        self.name = name
        self.fcmToken = fcmToken
    }
}
