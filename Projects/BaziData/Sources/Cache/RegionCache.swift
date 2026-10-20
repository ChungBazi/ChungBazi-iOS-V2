// Copyright © 2026 ChungBazi. All rights reserved.

import BaziDomain

/// 시도/시군구(행정구역) 인메모리 캐시. 세션 동안 유지된다.
/// 행정구역은 사실상 고정이라 무효화(TTL)가 필요 없고, 시도 코드 수가 유한해 상한/축출도 두지 않는다.
/// 유저 스코프가 아니므로 로그아웃 시 비우지 않는다.
/// 최초 동시 호출은 하나의 요청으로 합쳐(coalescing) 중복 네트워크 호출을 막는다.
public actor RegionCache {

    private var sido: [RegionInfo]?
    private var sigungu: [String: [RegionInfo]] = [:]
    private var sidoTask: Task<[RegionInfo], Error>?
    private var sigunguTasks: [String: Task<[RegionInfo], Error>] = [:]

    public init() {}

    /// 캐시가 있으면 즉시, 없으면 `load`로 한 번만 요청한다. 진행 중이면 같은 작업을 공유하고, 빈 결과는 캐시하지 않는다.
    func sidoList(load: @Sendable @escaping () async throws -> [RegionInfo]) async throws -> [RegionInfo] {
        if let sido { return sido }
        if let sidoTask { return try await sidoTask.value }

        let task = Task { try await load() }
        sidoTask = task
        defer { sidoTask = nil }
        let list = try await task.value
        if !list.isEmpty { sido = list }
        return list
    }

    /// `sidoList(load:)`와 같은 규칙을 시도 코드별로 적용한다.
    func sigunguList(
        sidoCode: String,
        load: @Sendable @escaping () async throws -> [RegionInfo]
    ) async throws -> [RegionInfo] {
        if let cached = sigungu[sidoCode] { return cached }
        if let task = sigunguTasks[sidoCode] { return try await task.value }

        let task = Task { try await load() }
        sigunguTasks[sidoCode] = task
        defer { sigunguTasks[sidoCode] = nil }
        let list = try await task.value
        if !list.isEmpty { sigungu[sidoCode] = list }
        return list
    }
}
