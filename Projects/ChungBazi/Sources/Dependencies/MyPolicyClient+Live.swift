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
        let deadlineUpcomingUseCase: any FetchDeadlineUpcomingUseCase = FetchDeadlineUpcomingUseCaseImpl(myPolicyRepository: repository)
        let openEndedUseCase: any FetchOpenEndedPoliciesUseCase = FetchOpenEndedPoliciesUseCaseImpl(myPolicyRepository: repository)

        return MyPolicyClient(
            fetchDeadlineTeaser: {
                let policies = try await deadlineTeaserUseCase.execute()
                return policies.map(BaziPresentation.PolicySummaryVO.init)
            },
            fetchDeadlineUpcoming: { targetDate in
                let page = try await deadlineUpcomingUseCase.execute(targetDate: targetDate)
                return PolicyPageVO(page)
            },
            fetchOpenEnded: { cursor, size in
                let page = try await openEndedUseCase.execute(cursor: cursor, size: size)
                return PolicyPageVO(page)
            }
        )
    }()
}
