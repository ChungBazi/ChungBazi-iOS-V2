// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버와의 사용자 정보(닉네임, 온보딩) 통신을 담당한다.
public protocol UserRepository: Sendable {
    func updateName(_ name: String) async throws
    func submitOnboarding(_ info: OnboardingInfo) async throws -> String
    func getProfile() async throws -> UserProfile
    func getPolicyProfile() async throws -> OnboardingInfo
    func updatePolicyProfile(_ info: OnboardingInfo) async throws
    /// 회원 탈퇴시, 서버가 Apple revoke까지 처리한다.
    func withdraw(_ request: WithdrawRequest) async throws
}
