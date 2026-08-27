// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct ToggleLikeUseCaseImpl: ToggleLikeUseCase {

    private let policyDetailRepository: PolicyDetailRepository

    public init(policyDetailRepository: PolicyDetailRepository) {
        self.policyDetailRepository = policyDetailRepository
    }

    public func execute(policyId: Int, liked: Bool) async throws {
        if liked {
            try await policyDetailRepository.like(policyId: policyId)
        } else {
            try await policyDetailRepository.unlike(policyId: policyId)
        }
    }
}
