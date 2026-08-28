// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책을 공유하는 메서드
public protocol PolicyShareService: Sendable {
    func shareToKakao(_ content: PolicyShareContent) async throws
}
