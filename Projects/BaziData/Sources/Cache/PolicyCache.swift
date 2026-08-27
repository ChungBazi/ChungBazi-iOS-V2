// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain

/// 홈 피드(aggregate) 인메모리 캐시. TTL이 지나면 만료로 취급한다.
/// composition root에서 1개만 만들어 HomeRepository에 공유 주입한다.
// TODO: 캐시가 여러 도메인으로 늘면 범용 인메모리 캐시 primitive는 BaziStorage로 분리하고, 도메인 특화 PolicyCache는 그 위에 둔다.
public actor PolicyCache {

    private var stored: (value: HomeFeed, storedAt: Date)?
    private let ttl: TimeInterval

    public init(ttl: TimeInterval = 300) {
        self.ttl = ttl
    }

    /// TTL 이내면 캐시된 홈 피드를, 아니면 nil을 반환한다.
    public func homeFeed(now: Date = Date()) -> HomeFeed? {
        guard let cached = stored, now.timeIntervalSince(cached.storedAt) < ttl else {
            return nil
        }
        return cached.value
    }

    public func setHomeFeed(_ value: HomeFeed, now: Date = Date()) {
        stored = (value, now)
    }

    /// 찜 낙관적 갱신: 캐시에 해당 정책이 있으면 liked만 바꾼다. TTL은 유지.
    public func updateLiked(policyId: Int, liked: Bool) {
        guard let cached = stored else { return }
        stored = (cached.value.updatingLiked(policyId: policyId, liked: liked), cached.storedAt)
    }
}
