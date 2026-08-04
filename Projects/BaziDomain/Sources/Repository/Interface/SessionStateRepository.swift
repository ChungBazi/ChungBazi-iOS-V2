// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 로컬에 저장된 세션 상태(닉네임 설정 여부, 온보딩 완료 여부) 관리를 담당한다.
public protocol SessionStateRepository: Sendable {
    var hasSetNickname: Bool { get }
    var hasCompletedOnboarding: Bool { get }
    func setHasSetNickname(_ value: Bool)
    func setHasCompletedOnboarding(_ value: Bool)
    func reset()
}
