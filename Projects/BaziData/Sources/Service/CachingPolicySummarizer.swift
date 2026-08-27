// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain

/// 지원 내용(supportContent) → 요약 결과 인메모리 캐시. 세션 동안 유지된다.
/// 요약은 내용에서 결정되고 변하지 않으므로 무효화가 필요 없다.
public actor SummaryCache {
    private var storage: [String: String] = [:]

    public init() {}

    func summary(for content: String) -> String? { storage[content] }
    func store(_ summary: String, for content: String) { storage[content] = summary }
}

/// PolicySummarizer 데코레이터: 이미 요약한 내용은 캐시에서 즉시 돌려줘 재요약(온디바이스 비용)을 피한다.
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
