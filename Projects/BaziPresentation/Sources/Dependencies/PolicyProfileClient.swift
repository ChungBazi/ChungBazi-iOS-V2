// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct PolicyProfileClient: Sendable {
    public var getPolicyProfile: @Sendable () async throws -> OnboardingInfo
    public var updatePolicyProfile: @Sendable (_ info: OnboardingInfo) async throws -> Void
    public var fetchSidoList: @Sendable () async throws -> [RegionInfo]
    public var fetchSigunguList: @Sendable (_ sidoCode: String) async throws -> [RegionInfo]
}

extension PolicyProfileClient: TestDependencyKey {
    public static let testValue = PolicyProfileClient()

    public static let previewValue = PolicyProfileClient(
        getPolicyProfile: {
            OnboardingInfo(
                birth: "2000-01-01",
                sidoCode: "SEOUL",
                sigunguCode: "",
                educationCode: .universityGraduated,
                employmentCode: .employed,
                incomeLevel: .level5,
                interestCategories: [.employmentPreparation, .housingCostSpace, .financeLiving],
                specialEligibilities: [.woman]
            )
        },
        updatePolicyProfile: { _ in },
        fetchSidoList: { [RegionInfo(code: "11", name: "서울특별시"), RegionInfo(code: "26", name: "부산광역시")] },
        fetchSigunguList: { _ in [RegionInfo(code: "11010", name: "종로구")] }
    )
}

extension DependencyValues {
    public var policyProfileClient: PolicyProfileClient {
        get { self[PolicyProfileClient.self] }
        set { self[PolicyProfileClient.self] = newValue }
    }
}
