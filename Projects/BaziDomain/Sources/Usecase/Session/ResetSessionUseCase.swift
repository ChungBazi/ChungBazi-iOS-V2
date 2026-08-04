// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 로그아웃/탈퇴 시 토큰과 로컬에 캐시해둔 세션 상태(닉네임 설정 여부, 온보딩 완료 여부)를 함께 지운다.
public protocol ResetSessionUseCase: Sendable {
    func execute()
}
