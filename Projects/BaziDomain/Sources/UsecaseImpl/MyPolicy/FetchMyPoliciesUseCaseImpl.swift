// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchMyPoliciesUseCaseImpl: FetchMyPoliciesUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute(category: PolicyCategory?, sort: String, cursor: String?, size: Int) async throws -> PolicyPage {
        try await myPolicyRepository.fetchMyPolicies(category: category, sort: sort, cursor: cursor, size: size)
    }
}
