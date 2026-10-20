// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 맞춤 조건을 수정한다.
public protocol UpdatePolicyProfileUseCase: Sendable {
    func execute(_ info: OnboardingInfo) async throws
}
