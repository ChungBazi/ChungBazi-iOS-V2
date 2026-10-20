// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension MyPolicyListClient: @retroactive DependencyKey {

    public static let liveValue: MyPolicyListClient = {
        let repository: any MyPolicyRepository = MyPolicyRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let fetchMyPoliciesUseCase: any FetchMyPoliciesUseCase = FetchMyPoliciesUseCaseImpl(myPolicyRepository: repository)

        return MyPolicyListClient(
            fetchMyPolicies: { category, sort, cursor, size in
                let page = try await fetchMyPoliciesUseCase.execute(
                    category: category?.toDomain(),
                    sort: sort,
                    cursor: cursor,
                    size: size
                )
                return PolicyPageVO(page)
            }
        )
    }()
}
