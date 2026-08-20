// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 프로필 > 로그인된 소셜 계정(35) 화면용 모델.
public struct SocialAccount: Equatable, Identifiable, Sendable {
    public enum Provider: Equatable, Sendable {
        case kakao
        case apple

        public var displayName: String {
            switch self {
            case .kakao: return "카카오톡"
            case .apple: return "Apple"
            }
        }
    }

    public let id: String
    public let provider: Provider
    public let email: String

    public init(id: String, provider: Provider, email: String) {
        self.id = id
        self.provider = provider
        self.email = email
    }
}

// MARK: - Mock

extension SocialAccount {

    // TODO: BaziDomain의 연동 계정 조회 UseCase가 준비되면 실제 서버 데이터로 교체한다.
    public static let mockList: [SocialAccount] = [
        SocialAccount(id: "1", provider: .kakao, email: "12345678@gmail.com"),
    ]
}
