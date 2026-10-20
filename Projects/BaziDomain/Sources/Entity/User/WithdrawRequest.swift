// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 회원 탈퇴 요청 정보. 서버(DELETE /me)로 전달된다.
public struct WithdrawRequest: Equatable, Sendable {
    public let reasons: [WithdrawReason]
    public let detail: String?

    public init(reasons: [WithdrawReason], detail: String? = nil) {
        self.reasons = reasons
        self.detail = detail
    }
}
