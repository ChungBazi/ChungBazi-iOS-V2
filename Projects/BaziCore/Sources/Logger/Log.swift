// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 앱 전역 기본 로거. `import BaziCore` 후 `Log.debug("...")` 로 바로 쓴다.
///
/// ```swift
/// Log.info("앱 시작")
/// Log.error("토큰 갱신 실패", category: .auth)
/// ```
///
/// 모듈을 별도 subsystem 으로 분리하려면 ``BaziLogger`` 참고.
public enum Log: BaziLogger {
    public static let subsystem = Bundle.main.bundleIdentifier ?? "com.yeonho.chungbazi"
}
