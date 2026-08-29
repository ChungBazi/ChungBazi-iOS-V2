// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버와의 사용자 정보(닉네임, 온보딩) 통신을 담당한다.
public protocol UserRepository: Sendable {
    func updateName(_ name: String) async throws
    func submitOnboarding(_ info: OnboardingInfo) async throws -> String
    func getProfile() async throws -> UserProfile
}
