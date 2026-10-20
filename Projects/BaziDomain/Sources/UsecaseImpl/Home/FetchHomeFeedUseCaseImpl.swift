// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct FetchHomeFeedUseCaseImpl: FetchHomeFeedUseCase {

    private let homeRepository: HomeRepository

    public init(homeRepository: HomeRepository) {
        self.homeRepository = homeRepository
    }

    public func execute(forceRefresh: Bool) async throws -> HomeFeed {
        try await homeRepository.fetchHomeFeed(forceRefresh: forceRefresh)
    }
}
