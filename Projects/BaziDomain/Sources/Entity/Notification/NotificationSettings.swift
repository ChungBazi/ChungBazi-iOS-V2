// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 알림 설정 (전체 / 내 정책 / 청바지).
public struct NotificationSettings: Equatable, Sendable {
    public let isAllOn: Bool
    public let isMyPolicyOn: Bool
    public let isChungBaziOn: Bool

    public init(isAllOn: Bool, isMyPolicyOn: Bool, isChungBaziOn: Bool) {
        self.isAllOn = isAllOn
        self.isMyPolicyOn = isMyPolicyOn
        self.isChungBaziOn = isChungBaziOn
    }
}
