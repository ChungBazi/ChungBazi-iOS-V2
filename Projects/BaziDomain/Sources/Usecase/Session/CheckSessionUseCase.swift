// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 앱 시작 시 토큰 보유 여부, 닉네임 설정 여부, 온보딩 완료 여부를 확인해 시작 화면 분기에 사용한다.
public protocol CheckSessionUseCase: Sendable {
    func execute() async -> (hasValidToken: Bool, hasNickname: Bool, hasCompletedOnboarding: Bool)
}
