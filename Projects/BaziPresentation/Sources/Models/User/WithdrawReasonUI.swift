// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 탈퇴 사유 화면용 VO. rawValue = 표시 문구. (서버로 보내기만 하므로 forward 매핑만 둔다)
public enum WithdrawReasonUI: String, CaseIterable, Equatable, Sendable {
    case policyDiscoveryDifficult = "원하는 정책을 찾기 어려워요."
    case insufficientPolicyInformation = "저에게 맞는 정책 추천이 부족해요."
    case noLongerNeeded = "이용할 일이 없어졌어요."
    case inconvenientApp = "앱 사용이 불편했어요."
    case frequentErrors = "오류가 자주 발생했어요."
    case other = "기타 이유가 있어요."

    public func toDomain() -> WithdrawReason {
        switch self {
        case .policyDiscoveryDifficult: return .policyDiscoveryDifficult
        case .insufficientPolicyInformation: return .insufficientPolicyInformation
        case .noLongerNeeded: return .noLongerNeeded
        case .inconvenientApp: return .inconvenientApp
        case .frequentErrors: return .frequentErrors
        case .other: return .other
        }
    }
}
