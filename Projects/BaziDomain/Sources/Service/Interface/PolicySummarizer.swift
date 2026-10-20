// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 지원 내용을 온디바이스 AI로 요약하는 서비스.
public protocol PolicySummarizer: Sendable {
    /// 현재 기기/OS에서 온디바이스 요약이 가능한지.
    func isAvailable() -> Bool
    /// 지원 내용을 요약한다. 불가/실패 시 nil(원문 fallback).
    func summarize(_ text: String) async -> String?
}
