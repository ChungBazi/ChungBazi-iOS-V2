// Copyright © 2026 ChungBazi. All rights reserved.

import Foundation

public struct CustomPolicyGuideUseCaseImpl: CustomPolicyGuideUseCase {

    private let appPreferenceRepository: AppPreferenceRepository

    public init(appPreferenceRepository: AppPreferenceRepository) {
        self.appPreferenceRepository = appPreferenceRepository
    }

    public func hasSeen() -> Bool {
        appPreferenceRepository.hasSeenCustomPolicyGuide
    }

    public func markSeen() {
        appPreferenceRepository.markCustomPolicyGuideSeen()
    }
}
