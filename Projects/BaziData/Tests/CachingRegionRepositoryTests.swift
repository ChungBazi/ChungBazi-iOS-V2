// Copyright © 2026 ChungBazi. All rights reserved.

import Testing

import BaziDomain
@testable import BaziData

/// 호출 횟수를 세는 스파이. 시도/시군구(코드별) base 호출 횟수를 기록한다.
private actor SpyRegionRepository: RegionRepository {
    private(set) var sidoCallCount = 0
    private(set) var sigunguCallCounts: [String: Int] = [:]

    func fetchSidoList() async throws -> [RegionInfo] {
        sidoCallCount += 1
        return [RegionInfo(code: "11", name: "서울특별시")]
    }

    func fetchSigunguList(sidoCode: String) async throws -> [RegionInfo] {
        sigunguCallCounts[sidoCode, default: 0] += 1
        return [RegionInfo(code: sidoCode + "010", name: "종로구")]
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
}
