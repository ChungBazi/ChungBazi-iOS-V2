// Copyright © 2026 ChungBazi. All rights reserved.

import UIKit

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
            shareToKakao: { content, thumbnail in
                // 공유 URL 생성은 서비스가, 앱 전환(open)은 Composition Root가 담당한다.
                let url = try await shareService.makeKakaoShareURL(content, thumbnail: thumbnail)
                await MainActor.run { UIApplication.shared.open(url) }
            }
        )
    }()
}
