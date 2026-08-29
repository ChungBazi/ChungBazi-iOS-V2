// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchDeadlineDatePoliciesUseCaseImpl: FetchDeadlineDatePoliciesUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute(targetDate: String, sort: String, cursor: String?, size: Int) async throws -> PolicyPage {
        try await myPolicyRepository.fetchDeadlineDatePolicies(targetDate: targetDate, sort: sort, cursor: cursor, size: size)
    }
}
