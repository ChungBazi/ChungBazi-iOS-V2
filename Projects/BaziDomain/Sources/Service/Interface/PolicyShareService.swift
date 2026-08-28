// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 SDK를 통해 정책을 공유한다.
public protocol PolicyShareService: Sendable {
    func shareToKakao(_ content: PolicyShareContent) async throws
}
