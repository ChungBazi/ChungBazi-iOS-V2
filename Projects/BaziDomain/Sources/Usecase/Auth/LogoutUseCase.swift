// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 서버 로그아웃. 로컬 세션 초기화는 호출측(SessionClient)이 성공 시에만 수행한다.
public protocol LogoutUseCase: Sendable {
    func execute() async throws
}
