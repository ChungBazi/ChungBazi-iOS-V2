// Copyright © 2026 ChungBazi. All rights reserved.

public protocol AppConfigUseCase: Sendable {
    /// 서버 갱신 후 실행 게이트를 평가한다. (fetch 실패 시 캐시/기본값으로 판정)
    func evaluateGate() async -> AppLaunchGate
    /// 활성값 기준 현재 버전 < latest 여부. (네트워크 없음)
    func isUpdateAvailable() -> Bool
}
