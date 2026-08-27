// Copyright © 2026 ChungBazi. All rights reserved.

/// 지원 내용(supportContent) → 요약 결과 인메모리 캐시. 세션 동안 유지된다.
/// 요약은 내용에서 결정되고 변하지 않으므로 무효화가 필요 없다.
public actor SummaryCache {
    private var storage: [String: String] = [:]

    public init() {}

    func summary(for content: String) -> String? { storage[content] }
    func store(_ summary: String, for content: String) { storage[content] = summary }
}
