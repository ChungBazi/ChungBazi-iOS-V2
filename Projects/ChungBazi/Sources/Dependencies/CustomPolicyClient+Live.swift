// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziData
import BaziDomain
import BaziPresentation
import BaziStorage

extension CustomPolicyClient: @retroactive DependencyKey {

    public static let liveValue: CustomPolicyClient = {
        let policyDetailRepository: any PolicyDetailRepository = PolicyDetailRepositoryImpl(
            networkProvider: AppDependencies.networkProvider,
            cache: AppDependencies.policyCache
        )
        let fetchPolicyCardUseCase: any FetchPolicyCardUseCase = FetchPolicyCardUseCaseImpl(policyDetailRepository: policyDetailRepository)
        let summarizeUseCase: any SummarizePolicyUseCase = SummarizePolicyUseCaseImpl(summarizer: DefaultPolicySummarizer())

        let appPreferenceRepository: any AppPreferenceRepository = AppPreferenceRepositoryImpl(storage: UserDefaultsStorage())
        let guideUseCase: any CustomPolicyGuideUseCase = CustomPolicyGuideUseCaseImpl(appPreferenceRepository: appPreferenceRepository)

        return CustomPolicyClient(
            fetchCard: { policyId in
                PolicyCardVO(try await fetchPolicyCardUseCase.execute(policyId: policyId))
            },
            hasSeenGuide: { guideUseCase.hasSeen() },
            markGuideSeen: { guideUseCase.markSeen() },
            isAISummaryAvailable: { summarizeUseCase.isAvailable() },
            summarize: { supportContent in await summarizeUseCase.summarize(supportContent) }
        )
    }()
}
