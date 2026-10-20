// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension CategoryPolicyClient: @retroactive DependencyKey {

    public static let liveValue: CategoryPolicyClient = {
        let homeRepository = AppDependencies.homeRepository
        let fetchCategoryPoliciesUseCase: any FetchCategoryPoliciesUseCase = FetchCategoryPoliciesUseCaseImpl(homeRepository: homeRepository)
        let fetchPersonalizedUseCase: any FetchPersonalizedPoliciesUseCase = FetchPersonalizedPoliciesUseCaseImpl(homeRepository: homeRepository)

        return CategoryPolicyClient(
            fetchPolicies: { category, sort, cursor, size in
                let page = try await fetchCategoryPoliciesUseCase.execute(
                    category: category.toDomain(),
                    sort: sort,
                    cursor: cursor,
                    size: size
                )
                return PolicyPageVO(page)
            },
            fetchPersonalized: { category in
                let policies = try await fetchPersonalizedUseCase.execute(category: category.toDomain())
                return policies.map(BaziPresentation.PolicySummaryVO.init)
            }
        )
    }()
}
