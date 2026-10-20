// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct OnboardingClient: Sendable {
    public var fetchSidoList: @Sendable () async throws -> [RegionInfo]
    public var fetchSigunguList: @Sendable (_ sidoCode: String) async throws -> [RegionInfo]
    public var submitOnboarding: @Sendable (_ info: OnboardingInfo) async throws -> String
}

extension OnboardingClient: TestDependencyKey {
    public static let testValue = OnboardingClient()

    public static let previewValue = OnboardingClient(
        fetchSidoList: { [RegionInfo(code: "11", name: "서울특별시"), RegionInfo(code: "26", name: "부산광역시")] },
        fetchSigunguList: { _ in [RegionInfo(code: "11010", name: "종로구")] },
        submitOnboarding: { _ in "바지" }
    )
}

extension DependencyValues {
    public var onboardingClient: OnboardingClient {
        get { self[OnboardingClient.self] }
        set { self[OnboardingClient.self] = newValue }
    }
}
