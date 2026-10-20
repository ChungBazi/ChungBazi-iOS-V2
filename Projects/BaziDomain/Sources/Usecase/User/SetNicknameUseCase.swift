// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 닉네임을 서버에 등록하고, 로컬 세션 상태에 닉네임 설정 완료 여부를 반영한다.
public protocol SetNicknameUseCase: Sendable {
    func execute(name: String) async throws
}
