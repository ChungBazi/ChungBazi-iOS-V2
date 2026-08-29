// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 마감일을 기기 캘린더에 이벤트로 추가한다.
public protocol AddCalendarEventUseCase: Sendable {
    /// `url`은 이벤트에 연결할 정책 상세 딥링크.
    func execute(title: String, date: Date, url: URL?) async throws
}
