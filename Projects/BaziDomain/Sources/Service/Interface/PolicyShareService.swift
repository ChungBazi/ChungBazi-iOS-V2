// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 카카오 공유 URL을 생성하는 서비스. 실제 앱 전환(open)은 상위 계층이 담당한다.
public protocol PolicyShareService: Sendable {
    /// `thumbnail`이 있으면 카카오 서버에 업로드해 공유 이미지로 첨부한다(없으면 이미지 없이 공유).
    func makeKakaoShareURL(_ content: PolicyShareContent, thumbnail: ShareThumbnail?) async throws -> URL
}
