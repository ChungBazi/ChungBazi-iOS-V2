// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

extension WithdrawRequest {
    func toRequestDTO() -> UserWithdrawalRequestDTO {
        UserWithdrawalRequestDTO(
            reasons: reasons.map(\.rawValue),
            detail: detail
        )
    }
}
