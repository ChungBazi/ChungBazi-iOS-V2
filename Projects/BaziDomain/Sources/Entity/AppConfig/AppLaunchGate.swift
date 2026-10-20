// Copyright © 2026 ChungBazi. All rights reserved.

/// 앱 실행 시 게이트 상태. 점검 > 강제 업데이트 > 정상 우선순위로 평가된다.
public enum AppLaunchGate: Equatable, Sendable {
    case normal
    case maintenance(message: String)
    case forceUpdate
}
