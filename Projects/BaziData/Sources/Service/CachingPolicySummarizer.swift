// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain

/// PolicySummarizer 데코레이터: 이미 요약한 내용은 SummaryCache에서 즉시 돌려줘 재요약(온디바이스 비용)을 피한다.
public struct CachingPolicySummarizer: PolicySummarizer {
    private let base: any PolicySummarizer
    private let cache: SummaryCache

    public init(wrapping base: any PolicySummarizer, cache: SummaryCache = SummaryCache()) {
        self.base = base
        self.cache = cache
    }

    public func isAvailable() -> Bool { base.isAvailable() }

    public func summarize(_ text: String) async -> String? {
        if let cached = await cache.summary(for: text) { return cached }
        guard let summary = await base.summarize(text) else { return nil }
        await cache.store(summary, for: text)
        return summary
    }
}
