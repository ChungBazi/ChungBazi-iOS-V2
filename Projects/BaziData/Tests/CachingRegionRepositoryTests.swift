// Copyright © 2026 ChungBazi. All rights reserved.

import Testing

import BaziDomain
@testable import BaziData

/// 호출 횟수를 세는 스파이. 시도/시군구(코드별) base 호출 횟수를 기록한다.
private actor SpyRegionRepository: RegionRepository {
    private let sidoResult: [RegionInfo]
    private(set) var sidoCallCount = 0
    private(set) var sigunguCallCounts: [String: Int] = [:]

    init(sidoResult: [RegionInfo] = [RegionInfo(code: "11", name: "서울특별시")]) {
        self.sidoResult = sidoResult
    }

    func fetchSidoList() async throws -> [RegionInfo] {
        sidoCallCount += 1
        return sidoResult
    }

    func fetchSigunguList(sidoCode: String) async throws -> [RegionInfo] {
        sigunguCallCounts[sidoCode, default: 0] += 1
        return [RegionInfo(code: sidoCode + "010", name: "종로구")]
    }
}

/// base 호출을 신호로 붙잡아 두는 스파이. 동시 최초 호출의 코얼레싱을 결정적으로 검증한다.
private actor GatedSpyRegionRepository: RegionRepository {
    private(set) var sidoCallCount = 0
    private var started: CheckedContinuation<Void, Never>?
    private var releases: [CheckedContinuation<Void, Never>] = []

    /// 첫 base 호출이 시작될 때까지 기다린다.
    func waitUntilStarted() async {
        guard sidoCallCount == 0 else { return }
        await withCheckedContinuation { started = $0 }
    }

    /// 붙잡아 둔 base 호출을 모두 풀어 준다.
    func releaseAll() {
        releases.forEach { $0.resume() }
        releases.removeAll()
    }

    func fetchSidoList() async throws -> [RegionInfo] {
        sidoCallCount += 1
        started?.resume()
        started = nil
        await withCheckedContinuation { releases.append($0) }
        return [RegionInfo(code: "11", name: "서울특별시")]
    }

    func fetchSigunguList(sidoCode: String) async throws -> [RegionInfo] {
        [RegionInfo(code: sidoCode + "010", name: "종로구")]
    }
}

struct CachingRegionRepositoryTests {

    @Test
    func 시도목록은_최초1회만_base를_호출한다() async throws {
        let spy = SpyRegionRepository()
        let sut = CachingRegionRepository(wrapping: spy)

        let first = try await sut.fetchSidoList()
        let second = try await sut.fetchSidoList()

        #expect(await spy.sidoCallCount == 1)
        #expect(first == second)
    }

    @Test
    func 시군구는_시도코드별로_최초1회만_base를_호출한다() async throws {
        let spy = SpyRegionRepository()
        let sut = CachingRegionRepository(wrapping: spy)

        _ = try await sut.fetchSigunguList(sidoCode: "11")
        _ = try await sut.fetchSigunguList(sidoCode: "11")
        _ = try await sut.fetchSigunguList(sidoCode: "26")

        #expect(await spy.sigunguCallCounts["11"] == 1)
        #expect(await spy.sigunguCallCounts["26"] == 1)
    }

    @Test
    func 빈_결과는_캐시하지_않아_다음_호출에_다시_요청한다() async throws {
        let spy = SpyRegionRepository(sidoResult: [])
        let sut = CachingRegionRepository(wrapping: spy)

        _ = try await sut.fetchSidoList()
        _ = try await sut.fetchSidoList()

        // 빈 성공 응답은 캐시되지 않으므로 두 번째 호출도 base로 내려간다.
        #expect(await spy.sidoCallCount == 2)
    }

    @Test
    func 동시_최초호출은_진행중_요청을_공유해_base를_한번만_호출한다() async throws {
        let spy = GatedSpyRegionRepository()
        let sut = CachingRegionRepository(wrapping: spy)

        // 첫 호출을 시작해 base 요청이 진행 중(붙잡힌) 상태로 만든다.
        async let first = sut.fetchSidoList()
        await spy.waitUntilStarted()

        // 진행 중인 동안 두 번째 호출이 들어오면 같은 작업을 기다려야 한다(추가 base 호출 없음).
        async let second = sut.fetchSidoList()
        // 두 번째 호출이 캐시 조회 지점까지 진행하도록 몇 번 양보한 뒤 붙잡은 요청을 푼다.
        for _ in 0..<10 { await Task.yield() }
        await spy.releaseAll()

        let results = try await [first, second]

        #expect(await spy.sidoCallCount == 1)
        #expect(results[0] == results[1])
    }
}
