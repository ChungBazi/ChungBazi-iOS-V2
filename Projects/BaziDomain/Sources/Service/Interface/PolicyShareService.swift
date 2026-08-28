// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 공유 URL을 생성하는 서비스. 실제 앱 전환(open)은 상위 계층이 담당한다.
public protocol PolicyShareService: Sendable {
    func makeKakaoShareURL(_ content: PolicyShareContent) async throws -> URL
}
