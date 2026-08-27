// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 온보딩 정보를 서버에 등록하고, 로컬 세션 상태에 온보딩 완료 여부를 반영한다. 서버가 돌려준 닉네임을 반환한다.
public protocol SubmitOnboardingUseCase: Sendable {
    func execute(_ info: OnboardingInfo) async throws -> String
}
