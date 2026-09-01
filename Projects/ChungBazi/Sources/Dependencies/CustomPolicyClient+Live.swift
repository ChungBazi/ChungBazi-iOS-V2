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
        // 재요약 회피: 세션 동안 supportContent→요약을 캐시한다(요약은 내용에서 결정되고 변하지 않음).
        // 소비자가 이 Client 하나뿐이라 데코레이터가 캐시를 자체 소유한다(liveValue 1회 생성 = 세션 싱글턴).
        let summarizeUseCase: any SummarizePolicyUseCase = SummarizePolicyUseCaseImpl(
            summarizer: CachingPolicySummarizer(wrapping: DefaultPolicySummarizer())
        )

        let appPreferenceRepository: any AppPreferenceRepository = AppPreferenceRepositoryImpl(storage: UserDefaultsStorage())
        let guideUseCase: any CustomPolicyGuideUseCase = CustomPolicyGuideUseCaseImpl(appPreferenceRepository: appPreferenceRepository)

        return CustomPolicyClient(
            fetchCards: { category in
                try await fetchPolicyCardUseCase.execute(category: category).map(PolicyCardVO.init)
            },
            hasSeenGuide: { guideUseCase.hasSeen() },
            markGuideSeen: { guideUseCase.markSeen() },
            isAISummaryAvailable: { summarizeUseCase.isAvailable() },
            summarize: { supportContent in await summarizeUseCase.summarize(supportContent) }
        )
    }()
}
