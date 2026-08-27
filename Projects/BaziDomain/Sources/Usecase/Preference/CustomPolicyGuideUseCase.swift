// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 맞춤정책 가이드 오버레이 노출 여부(최초 1회)를 관리한다.
public protocol CustomPolicyGuideUseCase: Sendable {
    /// 가이드를 본 적 있는지.
    func hasSeen() -> Bool
    /// 가이드를 봤다고 기록한다.
    func markSeen()
}
