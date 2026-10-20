// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

import BaziDomain
import BaziNetwork

public struct UserRepositoryImpl: UserRepository {

    private let networkProvider: NetworkProvider

    public init(networkProvider: NetworkProvider) {
        self.networkProvider = networkProvider
    }

    public func updateName(_ name: String) async throws {
        try await networkProvider.requestStatusCode(UserAPI.updateName(body: NameRequestDTO(name: name)))
    }

    public func submitOnboarding(_ info: OnboardingInfo) async throws -> String {
        let dto: OnboardingResponseDTO = try await networkProvider.request(UserAPI.onboarding(body: info.toRequestDTO()))
        return dto.nickname
    }

    public func getProfile() async throws -> UserProfile {
        let dto: UserInfoResponseDTO = try await networkProvider.request(UserAPI.getProfile)
        return dto.toEntity()
    }

    public func getPolicyProfile() async throws -> OnboardingInfo {
        let dto: PolicyProfileResponseDTO = try await networkProvider.request(UserAPI.getPolicyProfile)
        return dto.toEntity()
    }

    public func updatePolicyProfile(_ info: OnboardingInfo) async throws {
        try await networkProvider.requestStatusCode(UserAPI.updatePolicyProfile(body: info.toRequestDTO()))
    }

    public func withdraw(_ request: WithdrawRequest) async throws {
        try await networkProvider.requestStatusCode(UserAPI.withdraw(body: request.toRequestDTO()))
    }
}
