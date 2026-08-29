// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// iOS 기본 캘린더에 이벤트를 추가하는 기기 서비스(EventKit). 쓰기 전용 권한만 사용한다.
public protocol EventKitService: Sendable {
    /// 종일 이벤트를 추가한다. 권한이 없으면 요청하고, 거부/실패 시 `EventKitError`를 던진다.
    func addEvent(title: String, date: Date, notes: String?) async throws
}

/// EventKit 관련 도메인 에러.
public enum EventKitError: Error, Equatable {
    /// 캘린더 쓰기 권한이 거부됨.
    case accessDenied
    /// 이벤트 저장 실패.
    case saveFailed
}
