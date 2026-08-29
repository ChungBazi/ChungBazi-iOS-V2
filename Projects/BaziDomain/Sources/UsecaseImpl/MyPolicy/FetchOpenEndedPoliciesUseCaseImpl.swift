// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchOpenEndedPoliciesUseCaseImpl: FetchOpenEndedPoliciesUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute(cursor: String?, size: Int) async throws -> PolicyPage {
        try await myPolicyRepository.fetchOpenEndedPolicies(cursor: cursor, size: size)
    }
}
