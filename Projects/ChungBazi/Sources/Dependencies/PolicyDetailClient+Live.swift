// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation

extension PolicyDetailClient: @retroactive DependencyKey {

    public static let liveValue: PolicyDetailClient = {
        let repository: any PolicyDetailRepository = PolicyDetailRepositoryImpl(
            networkProvider: AppDependencies.networkProvider,
            cache: AppDependencies.policyCache
        )
        let fetchUseCase: any FetchPolicyDetailUseCase = FetchPolicyDetailUseCaseImpl(policyDetailRepository: repository)
        let shareService: any PolicyShareService = PolicyShareServiceImpl()

        return PolicyDetailClient(
            fetch: { policyId in
                PolicyDetailVO(try await fetchUseCase.execute(policyId: policyId))
            },
            shareToKakao: { try await shareService.shareToKakao($0) }
        )
    }()
}
