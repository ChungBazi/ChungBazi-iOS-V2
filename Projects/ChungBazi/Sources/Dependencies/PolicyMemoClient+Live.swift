// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension PolicyMemoClient: @retroactive DependencyKey {

    public static let liveValue: PolicyMemoClient = {
        let repository: any MyPolicyRepository = MyPolicyRepositoryImpl(
            networkProvider: AppDependencies.networkProvider
        )
        let fetchMemoUseCase: any FetchMemoUseCase = FetchMemoUseCaseImpl(myPolicyRepository: repository)
        let updateMemoUseCase: any UpdateMemoUseCase = UpdateMemoUseCaseImpl(myPolicyRepository: repository)

        return PolicyMemoClient(
            fetchMemo: { policyId in
                let memo = try await fetchMemoUseCase.execute(policyId: policyId)
                return PolicyMemoVO(memo)
            },
            updateMemo: { policyId, memo in
                try await updateMemoUseCase.execute(policyId: policyId, memo: memo)
            }
        )
    }()
}
