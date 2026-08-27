// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchPolicyCardUseCaseImpl: FetchPolicyCardUseCase {

    private let policyDetailRepository: PolicyDetailRepository

    public init(policyDetailRepository: PolicyDetailRepository) {
        self.policyDetailRepository = policyDetailRepository
    }

    public func execute(policyId: Int) async throws -> PolicyCard {
        try await policyDetailRepository.fetchPolicyCard(policyId: policyId)
    }
}
