// Copyright © 2026 ChungBazi. All rights reserved.

import ComposableArchitecture

import BaziDomain

@DependencyClient
public struct PolicyProfileClient: Sendable {
    public var getPolicyProfile: @Sendable () async throws -> OnboardingInfo
    public var updatePolicyProfile: @Sendable (_ info: OnboardingInfo) async throws -> Void
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
        updatePolicyProfile: { _ in }
    )
}

extension DependencyValues {
    public var policyProfileClient: PolicyProfileClient {
        get { self[PolicyProfileClient.self] }
        set { self[PolicyProfileClient.self] = newValue }
    }
}
