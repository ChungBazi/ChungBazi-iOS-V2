// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct MyPolicyRepositoryImpl: MyPolicyRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func fetchMyPolicies(category: PolicyCategory?, sort: String, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            MyPolicyAPI.getMyPolicies(category: category?.rawValue, sort: sort, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func fetchOpenEndedPolicies(cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            MyPolicyAPI.getOpenEndedPolicies(cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func fetchDeadlineTeaser() async throws -> [PolicySummary] {
        let dto: MyPolicyDeadlineResponseDTO = try await networkProvider.request(MyPolicyAPI.getDeadlinePolicies)
        return dto.policies.map { $0.toDomain() }
    }

    public func fetchDeadlineDatePolicies(targetDate: String, sort: String, cursor: String?, size: Int) async throws -> PolicyPage {
        let dto: PolicyListResponseDTO = try await networkProvider.request(
            MyPolicyAPI.getDeadlineDatePolicies(targetDate: targetDate, sort: sort, cursor: cursor, size: size)
        )
        return dto.toDomain()
    }

    public func fetchCalendar(targetMonth: String) async throws -> [DateComponents] {
        let dto: CalendarResponseDTO = try await networkProvider.request(MyPolicyAPI.getCalendar(targetMonth: targetMonth))
        return dto.toDeadlineDayComponents()
    }

    public func fetchMemo(policyId: Int) async throws -> PolicyMemo {
        let dto: PolicyMemoResponseDTO = try await networkProvider.request(MyPolicyAPI.getMemo(policyId: policyId))
        return dto.toDomain()
    }

    public func updateMemo(policyId: Int, memo: String) async throws {
        try await networkProvider.requestStatusCode(
            MyPolicyAPI.updateMemo(policyId: policyId, body: PolicyMemoRequestDTO(memo: memo))
        )
    }
}
