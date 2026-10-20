// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchMemoUseCaseImpl: FetchMemoUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute(policyId: Int) async throws -> PolicyMemo {
        try await myPolicyRepository.fetchMemo(policyId: policyId)
    }
}
