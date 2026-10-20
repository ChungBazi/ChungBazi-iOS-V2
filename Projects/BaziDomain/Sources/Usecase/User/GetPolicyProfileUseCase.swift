// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 맞춤 조건(생년월일/지역/학력/취업/소득/관심분야)을 조회한다.
public protocol GetPolicyProfileUseCase: Sendable {
    func execute() async throws -> OnboardingInfo
}
