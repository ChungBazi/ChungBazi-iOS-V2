// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 찜/찜 해제를 처리한다.
public protocol ToggleLikeUseCase: Sendable {
    /// - Parameter liked: true면 찜, false면 찜 해제.
    func execute(policyId: Int, liked: Bool) async throws
}
