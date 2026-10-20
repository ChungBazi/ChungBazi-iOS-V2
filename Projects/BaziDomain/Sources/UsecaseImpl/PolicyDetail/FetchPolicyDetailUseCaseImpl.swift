// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchPolicyDetailUseCaseImpl: FetchPolicyDetailUseCase {

    private let policyDetailRepository: PolicyDetailRepository

    public init(policyDetailRepository: PolicyDetailRepository) {
        self.policyDetailRepository = policyDetailRepository
    }

    public func execute(policyId: Int) async throws -> PolicyDetail {
        try await policyDetailRepository.fetchPolicyDetail(policyId: policyId)
    }
}
