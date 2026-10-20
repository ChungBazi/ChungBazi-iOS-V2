// Copyright © 2026 ChungBazi. All rights reserved.

/// 지원 내용(supportContent) → 요약 결과 인메모리 캐시. 세션 동안 유지된다.
/// 요약은 내용에서 결정되고 변하지 않으므로 무효화(TTL)는 필요 없고,
/// 무한 증식만 막도록 최근 사용 순(LRU) 상한만 둔다.
public actor SummaryCache {

    private let capacity: Int
    private var storage: [String: String] = [:]
    /// 접근 순서(맨 앞이 가장 오래됨, 맨 뒤가 가장 최근). 초과 시 앞에서부터 제거한다.
    private var order: [String] = []

    public init(capacity: Int = 100) {
        self.capacity = capacity
    }

    func summary(for content: String) -> String? {
        guard let value = storage[content] else { return nil }
        touch(content)
        return value
    }

    func store(_ summary: String, for content: String) {
        if storage[content] == nil, order.count >= capacity {
            let oldest = order.removeFirst()
            storage[oldest] = nil
        }
        storage[content] = summary
        touch(content)
    }

    /// 해당 키를 "가장 최근 사용"으로 옮긴다.
    private func touch(_ content: String) {
        if let index = order.firstIndex(of: content) {
            order.remove(at: index)
        }
        order.append(content)
    }
}
