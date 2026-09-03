// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// `RegionRepository` 데코레이터: 시도/시군구는 세션 내내 고정이므로 한 번 받은 결과를 캐시해
/// 온보딩·정책맞춤조건 편집에서 화면 재진입/재선택 시 중복 네트워크 호출을 없앤다.
/// 성공 응답만 캐시하고, 실패는 그대로 전파한다.
public struct CachingRegionRepository: RegionRepository {

    private let base: any RegionRepository
    private let cache: RegionCache

    public init(wrapping base: any RegionRepository, cache: RegionCache = RegionCache()) {
        self.base = base
        self.cache = cache
    }

    public func fetchSidoList() async throws -> [RegionInfo] {
        if let cached = await cache.sidoList() { return cached }
        let list = try await base.fetchSidoList()
        await cache.setSidoList(list)
        return list
    }

    public func fetchSigunguList(sidoCode: String) async throws -> [RegionInfo] {
        if let cached = await cache.sigunguList(sidoCode: sidoCode) { return cached }
        let list = try await base.fetchSigunguList(sidoCode: sidoCode)
        await cache.setSigunguList(list, sidoCode: sidoCode)
        return list
    }
}
