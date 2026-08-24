// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

/// 홈 메인 피드를 조회한다.
public protocol FetchHomeFeedUseCase: Sendable {
    func execute(forceRefresh: Bool) async throws -> HomeFeed
}
