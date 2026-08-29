// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 회원 탈퇴 사유. rawValue = 서버 코드.
public enum WithdrawReason: String, CaseIterable, Sendable {
    case policyDiscoveryDifficult = "POLICY_DISCOVERY_DIFFICULT"
    case insufficientPolicyInformation = "INSUFFICIENT_POLICY_INFORMATION"
    case noLongerNeeded = "NO_LONGER_NEEDED"
    case inconvenientApp = "INCONVENIENT_APP"
    case frequentErrors = "FREQUENT_ERRORS"
    case other = "OTHER"
}
