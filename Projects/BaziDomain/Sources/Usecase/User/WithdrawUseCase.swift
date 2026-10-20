// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 회원 탈퇴. 서버 탈퇴(성공해야 진행) 후 카카오 계정이면 앱↔카카오 연결을 해제한다.
public protocol WithdrawUseCase: Sendable {
    func execute(_ request: WithdrawRequest) async throws
}
