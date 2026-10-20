// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 로그인(`kakaoLogin`/`appleLogin`)의 결과. 화면 분기용 계정 상태 플래그.
public struct AccountStatus: Equatable, Sendable {
    public let hasNickname: Bool
    public let hasCompletedOnboarding: Bool

    public init(hasNickname: Bool, hasCompletedOnboarding: Bool) {
        self.hasNickname = hasNickname
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
