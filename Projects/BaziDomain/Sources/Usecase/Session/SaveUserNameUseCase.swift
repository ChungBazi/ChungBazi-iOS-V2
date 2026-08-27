// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버에서 받은 사용자 닉네임을 로컬 세션 상태에 저장한다. 로그아웃/탈퇴 전까지 재사용한다.
public protocol SaveUserNameUseCase: Sendable {
    func execute(name: String)
}
