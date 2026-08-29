// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct UpdateMemoUseCaseImpl: UpdateMemoUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute(policyId: Int, memo: String) async throws {
        try await myPolicyRepository.updateMemo(policyId: policyId, memo: memo)
    }
}
