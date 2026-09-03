// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 시도/시군구(행정구역) 인메모리 캐시. 세션 동안 유지된다.
/// 행정구역은 사실상 고정이라 무효화(TTL)가 필요 없고, 시도 코드 수가 유한해 상한/축출도 두지 않는다.
/// 유저 스코프가 아니므로 로그아웃 시 비우지 않는다.
public actor RegionCache {

    private var sido: [RegionInfo]?
    private var sigungu: [String: [RegionInfo]] = [:]

    public init() {}

    func sidoList() -> [RegionInfo]? { sido }
    func setSidoList(_ list: [RegionInfo]) { sido = list }

    func sigunguList(sidoCode: String) -> [RegionInfo]? { sigungu[sidoCode] }
    func setSigunguList(_ list: [RegionInfo], sidoCode: String) { sigungu[sidoCode] = list }
}
