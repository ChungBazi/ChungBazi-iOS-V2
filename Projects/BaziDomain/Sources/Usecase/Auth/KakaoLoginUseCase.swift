// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 로그인 후 세션 상태(닉네임/온보딩 여부) 캐싱까지 수행한다.
public protocol KakaoLoginUseCase: Sendable {
    func execute() async throws -> AccountStatus
}
