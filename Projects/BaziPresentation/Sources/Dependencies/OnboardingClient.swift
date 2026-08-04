// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct OnboardingClient: Sendable {
    public var fetchSidoList: @Sendable () async throws -> [RegionEntity]
    public var fetchSigunguList: @Sendable (_ sidoCode: String) async throws -> [RegionEntity]
    public var submitOnboarding: @Sendable (_ info: OnboardingInfoEntity) async throws -> Void
}

extension OnboardingClient: TestDependencyKey {
    public static let testValue = OnboardingClient()

    public static let previewValue = OnboardingClient(
        fetchSidoList: { [RegionEntity(code: "11", name: "서울특별시"), RegionEntity(code: "26", name: "부산광역시")] },
        fetchSigunguList: { _ in [RegionEntity(code: "11010", name: "종로구")] },
        submitOnboarding: { _ in }
    )
}

extension DependencyValues {
    public var onboardingClient: OnboardingClient {
        get { self[OnboardingClient.self] }
        set { self[OnboardingClient.self] = newValue }
    }
}
