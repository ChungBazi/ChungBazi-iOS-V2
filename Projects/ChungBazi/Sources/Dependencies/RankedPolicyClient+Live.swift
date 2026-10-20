// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension RankedPolicyClient: @retroactive DependencyKey {

    public static let liveValue: RankedPolicyClient = {
        let homeRepository = AppDependencies.homeRepository
        let popular: any FetchPopularPoliciesUseCase = FetchPopularPoliciesUseCaseImpl(homeRepository: homeRepository)
        let deadline: any FetchDeadlinePoliciesUseCase = FetchDeadlinePoliciesUseCaseImpl(homeRepository: homeRepository)
        let latest: any FetchLatestPoliciesUseCase = FetchLatestPoliciesUseCaseImpl(homeRepository: homeRepository)

        return RankedPolicyClient(
            fetchPopular: { category, cursor, size in
                PolicyPageVO(try await popular.execute(category: category?.toDomain(), cursor: cursor, size: size))
            },
            fetchDeadline: { category, cursor, size in
                PolicyPageVO(try await deadline.execute(category: category?.toDomain(), cursor: cursor, size: size))
            },
            fetchLatest: { category, cursor, size in
                PolicyPageVO(try await latest.execute(category: category?.toDomain(), cursor: cursor, size: size))
            }
        )
    }()
}
