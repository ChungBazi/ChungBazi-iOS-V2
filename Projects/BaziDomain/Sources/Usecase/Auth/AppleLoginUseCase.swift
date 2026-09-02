// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 애플 로그인(자격증명 획득 → 서버 로그인) 후 세션 상태(닉네임/온보딩 여부) 캐싱까지 수행한다.
public protocol AppleLoginUseCase: Sendable {
    func execute() async throws -> AccountStatus
}
