// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 로컬 세션 상태에 저장된 사용자 닉네임을 읽는다(없으면 nil).
public protocol GetUserNameUseCase: Sendable {
    func execute() -> String?
}
