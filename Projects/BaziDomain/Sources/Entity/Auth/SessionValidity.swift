// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// `validateSession()`의 결과. 서버 기준 세션 유효성 판정.
public enum SessionValidity: Sendable {
    case valid          // 서버가 유효 확인
    case invalid        // 확정 만료 (401, reissue까지 실패)
    case indeterminate  // 판정 불가 (오프라인/타임아웃/서버오류) → 로컬 폴백
}
