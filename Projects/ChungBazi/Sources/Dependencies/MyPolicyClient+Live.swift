// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension MyPolicyClient: @retroactive DependencyKey {

    public static let liveValue: MyPolicyClient = {
        let repository: any MyPolicyRepository = MyPolicyRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let deadlineTeaserUseCase: any FetchDeadlineTeaserUseCase = FetchDeadlineTeaserUseCaseImpl(myPolicyRepository: repository)
        let deadlineDateUseCase: any FetchDeadlineDatePoliciesUseCase = FetchDeadlineDatePoliciesUseCaseImpl(myPolicyRepository: repository)
        let openEndedUseCase: any FetchOpenEndedPoliciesUseCase = FetchOpenEndedPoliciesUseCaseImpl(myPolicyRepository: repository)

        return MyPolicyClient(
            fetchDeadlineTeaser: {
                let policies = try await deadlineTeaserUseCase.execute()
                return policies.map(BaziPresentation.PolicySummaryVO.init)
            },
            fetchDeadlineDate: { targetDate, sort, cursor, size in
                let page = try await deadlineDateUseCase.execute(targetDate: targetDate, sort: sort, cursor: cursor, size: size)
                return PolicyPageVO(page)
            },
            fetchOpenEnded: { cursor, size in
                let page = try await openEndedUseCase.execute(cursor: cursor, size: size)
                return PolicyPageVO(page)
            }
        )
    }()
}
