// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchCalendarUseCaseImpl: FetchCalendarUseCase {

    private let myPolicyRepository: MyPolicyRepository

    public init(myPolicyRepository: MyPolicyRepository) {
        self.myPolicyRepository = myPolicyRepository
    }

    public func execute(targetMonth: String) async throws -> [DateComponents] {
        try await myPolicyRepository.fetchCalendar(targetMonth: targetMonth)
    }
}
