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

    // 캐시 조회·저장·코얼레싱·빈 결과 정책은 RegionCache가 담당한다.
    public func fetchSidoList() async throws -> [RegionInfo] {
        try await cache.sidoList { [base] in try await base.fetchSidoList() }
    }

    public func fetchSigunguList(sidoCode: String) async throws -> [RegionInfo] {
        try await cache.sigunguList(sidoCode: sidoCode) { [base] in
            try await base.fetchSigunguList(sidoCode: sidoCode)
        }
    }
}
