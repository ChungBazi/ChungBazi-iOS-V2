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

    public func submitOnboarding(_ info: OnboardingInfo) async throws {
        try await networkProvider.requestStatusCode(UserAPI.onboarding(body: info.toRequestDTO()))
    }
}
