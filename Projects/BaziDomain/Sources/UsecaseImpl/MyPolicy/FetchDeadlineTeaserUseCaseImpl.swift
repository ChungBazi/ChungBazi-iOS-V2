// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchDeadlineTeaserUseCaseImpl: FetchDeadlineTeaserUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute() async throws -> [PolicySummary] {
        try await myPolicyRepository.fetchDeadlineTeaser()
    }
}
