// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 정책 지원 내용의 온디바이스 AI 요약 역량.
public protocol SummarizePolicyUseCase: Sendable {
    /// 현재 기기/OS에서 요약이 가능한지(뒷면 로딩 표시 여부 판단용).
    func isAvailable() -> Bool
    /// 지원 내용을 요약한다. 불가/실패 시 nil(원문 fallback).
    func summarize(_ supportContent: String) async -> String?
}
